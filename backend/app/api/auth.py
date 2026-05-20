from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from datetime import datetime, timezone

from app.core.database import get_db
from app.core.security import verify_password, create_access_token, decode_access_token
from app.models.sys_user import SysUser
from app.schemas.common import LoginRequest, LoginResponse

router = APIRouter(prefix="/api/v1/auth", tags=["认证管理"])


@router.post("/login", response_model=LoginResponse)
def login(req: LoginRequest, db: Session = Depends(get_db)):
    """用户登录"""
    user = db.query(SysUser).filter(
        SysUser.username == req.username,
        SysUser.deleted == 0,
        SysUser.status == 1,
    ).first()

    if not user or not verify_password(req.password, user.password_hash):
        raise HTTPException(status_code=401, detail="用户名或密码错误")

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


@router.post("/logout")
def logout():
    """退出登录"""
    return {"code": 200, "message": "退出成功"}


@router.get("/userinfo", response_model=dict)
def get_userinfo(token: str = "", db: Session = Depends(get_db)):
    """获取当前用户信息"""
    payload = decode_access_token(token)
    if not payload:
        # Support both Authorization header and query param
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
