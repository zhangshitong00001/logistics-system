from fastapi import APIRouter, Depends, HTTPException, Body
from sqlalchemy.orm import Session
from datetime import datetime, timezone
import random
import string

from app.core.database import get_db
from app.core.security import verify_password, create_access_token, decode_access_token, get_password_hash
from app.models.sys_user import SysUser
from app.schemas.common import LoginRequest, LoginResponse, SendCodeRequest, RegisterRequest, CodeLoginRequest, ResetPasswordRequest
from app.core.redis_client import redis_client

router = APIRouter(prefix="/api/v1/auth", tags=["认证管理"])

CODE_EXPIRE = 300  # 验证码有效期5分钟


def _generate_code(length=6):
    return ''.join(random.choices(string.digits, k=length))


def _make_token_resp(user: SysUser):
    token = create_access_token(data={
        "sub": str(user.id),
        "username": user.username,
        "role_id": user.role_id,
    })
    return LoginResponse(
        access_token=token,
        user_id=user.id,
        username=user.username,
        real_name=user.real_name,
        role_id=user.role_id,
    )


@router.post("/login", response_model=LoginResponse)
def login(req: LoginRequest, db: Session = Depends(get_db)):
    """用户密码登录"""
    user = db.query(SysUser).filter(
        SysUser.username == req.username,
        SysUser.deleted == 0,
        SysUser.status == 1,
    ).first()

    if not user or not verify_password(req.password, user.password_hash):
        raise HTTPException(status_code=401, detail="用户名或密码错误")

    return _make_token_resp(user)


@router.post("/register")
def register(req: RegisterRequest, db: Session = Depends(get_db)):
    """用户注册"""
    if not req.username or not req.password:
        raise HTTPException(status_code=400, detail="用户名和密码不能为空")

    if len(req.password) < 6:
        raise HTTPException(status_code=400, detail="密码长度至少6位")

    # 验证码校验（如果提供了邮箱）
    if req.email:
        saved = redis_client.get(f"verify_code:{req.email}")
        if not saved or saved != req.code:
            raise HTTPException(status_code=400, detail="验证码错误或已过期")

    # 检查用户名唯一
    exists = db.query(SysUser).filter(
        SysUser.username == req.username, SysUser.deleted == 0,
    ).first()
    if exists:
        raise HTTPException(status_code=400, detail="用户名已存在")

    # 检查邮箱唯一
    if req.email:
        exists_email = db.query(SysUser).filter(
            SysUser.email == req.email, SysUser.deleted == 0,
        ).first()
        if exists_email:
            raise HTTPException(status_code=400, detail="邮箱已被注册")

    user = SysUser(
        username=req.username,
        password_hash=get_password_hash(req.password),
        real_name=req.real_name or req.username,
        phone=req.phone,
        email=req.email,
        role_id=2,
        status=1,
    )
    db.add(user)
    db.commit()
    db.refresh(user)

    if req.email:
        redis_client.delete(f"verify_code:{req.email}")

    resp = _make_token_resp(user)
    return {"code": 200, "message": "注册成功", "data": resp.model_dump()}


@router.post("/send-code")
def send_code(req: SendCodeRequest):
    """发送验证码到邮箱"""
    if not req.email:
        raise HTTPException(status_code=400, detail="邮箱不能为空")

    cooldown_key = f"verify_cooldown:{req.email}"
    if redis_client.get(cooldown_key):
        raise HTTPException(status_code=429, detail="发送过于频繁，请60秒后再试")

    code = _generate_code()
    redis_client.setex(f"verify_code:{req.email}", CODE_EXPIRE, code)
    redis_client.setex(cooldown_key, 60, "1")

    print(f"[验证码] 邮箱:{req.email} 用途:{req.purpose} 验证码:{code}（有效期5分钟）")

    return {"code": 200, "message": "验证码已发送", "data": {"email": req.email}}


@router.post("/code-login")
def code_login(req: CodeLoginRequest, db: Session = Depends(get_db)):
    """验证码登录"""
    if not req.email or not req.code:
        raise HTTPException(status_code=400, detail="邮箱和验证码不能为空")

    saved = redis_client.get(f"verify_code:{req.email}")
    if not saved or saved != req.code:
        raise HTTPException(status_code=400, detail="验证码错误或已过期")

    user = db.query(SysUser).filter(
        SysUser.email == req.email,
        SysUser.deleted == 0,
        SysUser.status == 1,
    ).first()

    if not user:
        raise HTTPException(status_code=404, detail="该邮箱未注册，请先注册")

    redis_client.delete(f"verify_code:{req.email}")
    return {"code": 200, "data": _make_token_resp(user).model_dump()}


@router.post("/reset-password")
def reset_password(req: ResetPasswordRequest, db: Session = Depends(get_db)):
    """重置密码"""
    if not req.email or not req.code or not req.new_password:
        raise HTTPException(status_code=400, detail="邮箱、验证码和新密码不能为空")

    if len(req.new_password) < 6:
        raise HTTPException(status_code=400, detail="密码长度至少6位")

    saved = redis_client.get(f"verify_code:{req.email}")
    if not saved or saved != req.code:
        raise HTTPException(status_code=400, detail="验证码错误或已过期")

    user = db.query(SysUser).filter(
        SysUser.email == req.email,
        SysUser.deleted == 0,
    ).first()
    if not user:
        raise HTTPException(status_code=404, detail="该邮箱未注册")

    user.password_hash = get_password_hash(req.new_password)
    db.commit()

    redis_client.delete(f"verify_code:{req.email}")
    return {"code": 200, "message": "密码重置成功"}


@router.post("/logout")
def logout():
    """退出登录"""
    return {"code": 200, "message": "退出成功"}


@router.get("/userinfo", response_model=dict)
def get_userinfo(token: str = "", db: Session = Depends(get_db)):
    """获取当前用户信息"""
    payload = decode_access_token(token)
    if not payload:
        raise HTTPException(status_code=401, detail="无效Token")

    user = db.query(SysUser).filter(
        SysUser.id == int(payload["sub"]),
        SysUser.deleted == 0,
    ).first()

    if not user:
        raise HTTPException(status_code=404, detail="用户不存在")

    return {
        "code": 200,
        "data": {
            "id": user.id,
            "username": user.username,
            "real_name": user.real_name,
            "phone": user.phone,
            "email": user.email,
            "role_id": user.role_id,
        }
    }
