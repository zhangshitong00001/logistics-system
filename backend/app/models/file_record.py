from sqlalchemy import Column, Integer, String, DateTime, Text
from sqlalchemy.sql import func
from app.core.database import Base


class FileRecord(Base):
    """文件记录表"""
    __tablename__ = 'file_record'

    id = Column(Integer, primary_key=True, autoincrement=True)
    file_no = Column(String(64), unique=True, nullable=False, comment='文件编号')
    file_name = Column(String(256), nullable=False, comment='文件名')
    file_type = Column(String(32), nullable=False, comment='文件类型:loading_list/invoice/packing_list/declaration/certificate')
    version = Column(String(16), default='v1.0', comment='版本号')
    batch_no = Column(String(64), comment='关联批次号')
    file_path = Column(String(512), comment='文件路径')
    file_size = Column(Integer, default=0, comment='文件大小(bytes)')
    status = Column(Integer, default=0, comment='状态:0待生成1已生成2已作废')
    creator = Column(String(64), comment='创建人')
    create_time = Column(DateTime, server_default=func.now())
    update_time = Column(DateTime, server_default=func.now(), onupdate=func.now())
    deleted = Column(Integer, default=0)


class FileTemplate(Base):
    """文件模板表"""
    __tablename__ = 'file_template'

    id = Column(Integer, primary_key=True, autoincrement=True)
    template_name = Column(String(128), nullable=False, comment='模板名称')
    template_type = Column(String(32), nullable=False, comment='模板类型')
    file_path = Column(String(512), comment='模板文件路径')
    description = Column(Text, comment='描述')
    create_time = Column(DateTime, server_default=func.now())
    update_time = Column(DateTime, server_default=func.now(), onupdate=func.now())
    deleted = Column(Integer, default=0)
