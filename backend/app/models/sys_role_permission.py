from sqlalchemy import Column, Integer, ForeignKey, UniqueConstraint
from app.core.database import Base


class SysRolePermission(Base):
    """角色-权限关联表"""
    __tablename__ = 'sys_role_permission'
    __table_args__ = (UniqueConstraint('role_id', 'permission_id', name='uq_role_perm'),)

    id = Column(Integer, primary_key=True, autoincrement=True)
    role_id = Column(Integer, ForeignKey('sys_role.id'), nullable=False, comment='角色ID')
    permission_id = Column(Integer, ForeignKey('sys_permission.id'), nullable=False, comment='权限ID')
