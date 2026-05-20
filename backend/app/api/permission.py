from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from sqlalchemy import func
from app.core.database import get_db
from app.core.security import get_password_hash
from app.models.sys_user import SysUser
from app.models.sys_role import SysRole
from app.models.sys_permission import SysPermission
from app.models.sys_role_permission import SysRolePermission
from app.models.sys_operation_log import SysOperationLog

router = APIRouter(prefix="/api/v1/permission", tags=["权限管理"])


@router.get("/role")
def get_roles(page: int = Query(1, ge=1), size: int = Query(20, ge=1, le=100), db: Session = Depends(get_db)):
    """角色列表"""
    q = db.query(SysRole).filter(SysRole.deleted == 0)
    total = q.count()
    records = q.order_by(SysRole.create_time.desc()).offset((page - 1) * size).limit(size).all()

    return {
        "code": 200,
        "data": {
            "records": [{
                "id": r.id, "role_name": r.role_name, "role_code": r.role_code,
                "description": r.description, "status": r.status,
            } for r in records],
            "total": total, "page": page, "size": size,
            "pages": (total + size - 1) // size,
        }
    }


@router.post("/role")
def create_role(role_name: str = "", role_code: str = "", description: str = "", db: Session = Depends(get_db)):
    """创建角色"""
    role = SysRole(role_name=role_name, role_code=role_code, description=description)
    db.add(role)
    db.commit()
    return {"code": 200, "data": {"role_id": role.id}}


@router.put("/role/{role_id}/permissions")
def set_role_permissions(role_id: int, permission_ids: list = [], db: Session = Depends(get_db)):
    """配置角色权限"""
    # Clear existing
    db.query(SysRolePermission).filter(SysRolePermission.role_id == role_id).delete()
    # Add new
    for perm_id in permission_ids:
        db.add(SysRolePermission(role_id=role_id, permission_id=perm_id))
    db.commit()
    return {"code": 200, "message": "权限配置成功"}


@router.get("/user")
def get_users(page: int = Query(1, ge=1), size: int = Query(20, ge=1, le=100), db: Session = Depends(get_db)):
    """用户列表"""
    q = db.query(SysUser).filter(SysUser.deleted == 0)
    total = q.count()
    records = q.order_by(SysUser.create_time.desc()).offset((page - 1) * size).limit(size).all()

    return {
        "code": 200,
        "data": {
            "records": [{
                "id": r.id, "username": r.username, "real_name": r.real_name,
                "phone": r.phone, "email": r.email, "role_id": r.role_id, "status": r.status,
            } for r in records],
            "total": total, "page": page, "size": size,
            "pages": (total + size - 1) // size,
        }
    }


@router.post("/user")
def create_user(
    username: str = "", password: str = "", real_name: str = "",
    phone: str = "", email: str = "", role_id: int = 0,
    db: Session = Depends(get_db),
):
    """创建用户"""
    if db.query(SysUser).filter(SysUser.username == username, SysUser.deleted == 0).first():
        return {"code": 400, "message": "用户名已存在"}
    user = SysUser(
        username=username,
        password_hash=get_password_hash(password),
        real_name=real_name, phone=phone, email=email,
        role_id=role_id if role_id else None,
    )
    db.add(user)
    db.commit()
    return {"code": 200, "data": {"user_id": user.id}}


@router.put("/user/{user_id}")
def update_user(
    user_id: int, real_name: str = "", phone: str = "",
    email: str = "", role_id: int = 0, status: int = 1,
    db: Session = Depends(get_db),
):
    """更新用户"""
    user = db.query(SysUser).filter(SysUser.id == user_id, SysUser.deleted == 0).first()
    if not user:
        return {"code": 404, "message": "用户不存在"}
    if real_name: user.real_name = real_name
    if phone: user.phone = phone
    if email: user.email = email
    if role_id: user.role_id = role_id
    user.status = status
    db.commit()
    return {"code": 200, "message": "更新成功"}


@router.get("/log")
def get_logs(page: int = Query(1, ge=1), size: int = Query(20, ge=1, le=100), db: Session = Depends(get_db)):
    """操作日志"""
    q = db.query(SysOperationLog)
    total = q.count()
    records = q.order_by(SysOperationLog.create_time.desc()).offset((page - 1) * size).limit(size).all()
    return {
        "code": 200,
        "data": {
            "records": [{
                "id": r.id, "username": r.username, "module": r.module,
                "action": r.action, "target": r.target,
                "ip_address": r.ip_address, "duration_ms": r.duration_ms,
                "create_time": str(r.create_time),
            } for r in records],
            "total": total, "page": page, "size": size,
            "pages": (total + size - 1) // size,
        }
    }
