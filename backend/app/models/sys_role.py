from sqlalchemy import Column, Integer, String, DateTime, Text
from sqlalchemy.sql import func
from app.core.database import Base


class SysRole(Base):
    """角色表"""
    __tablename__ = 'sys_role'

    id = Column(Integer, primary_key=True, autoincrement=True)
    role_name = Column(String(64), nullable=False, comment='角色名称')
    role_code = Column(String(64), unique=True, nullable=False, comment='角色编码')
    description = Column(String(256), comment='描述')
    status = Column(Integer, default=1, comment='状态:1启用0禁用')
    create_time = Column(DateTime, server_default=func.now())
    update_time = Column(DateTime, server_default=func.now(), onupdate=func.now())
    deleted = Column(Integer, default=0)
