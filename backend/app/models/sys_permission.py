from sqlalchemy import Column, Integer, String, DateTime
from sqlalchemy.sql import func
from app.core.database import Base


class SysPermission(Base):
    """权限表"""
    __tablename__ = 'sys_permission'

    id = Column(Integer, primary_key=True, autoincrement=True)
    perm_name = Column(String(64), nullable=False, comment='权限名称')
    perm_code = Column(String(128), unique=True, nullable=False, comment='权限编码')
    module = Column(String(64), comment='所属模块')
    action = Column(String(32), comment='操作类型:view/edit/delete')
    create_time = Column(DateTime, server_default=func.now())
    update_time = Column(DateTime, server_default=func.now(), onupdate=func.now())
    deleted = Column(Integer, default=0)
