from sqlalchemy import Column, Integer, String, DateTime, Numeric, Text
from sqlalchemy.sql import func
from app.core.database import Base


class CustomsDeclaration(Base):
    """报关/清关申请表"""
    __tablename__ = 'customs_declaration'

    id = Column(Integer, primary_key=True, autoincrement=True)
    declaration_no = Column(String(64), unique=True, nullable=False, comment='报关单号')
    batch_no = Column(String(64), nullable=False, comment='批次号')
    sku_info = Column(Text, comment='货物信息(JSON)')
    total_value = Column(Numeric(18, 2), comment='总金额')
    currency = Column(String(8), default='USD', comment='币种')
    customs_office = Column(String(128), comment='报关口岸')
    declaration_type = Column(String(16), comment='类型:export出口/import进口')
    status = Column(Integer, default=0, comment='状态:0待提交1审核中2已通过3已驳回')
    review_comment = Column(Text, comment='审核意见')
    submitter = Column(String(64), comment='提交人')
    review_time = Column(DateTime, comment='审核时间')
    file_ids = Column(Text, comment='附件文件ID(JSON数组)')
    create_time = Column(DateTime, server_default=func.now())
    update_time = Column(DateTime, server_default=func.now(), onupdate=func.now())
    deleted = Column(Integer, default=0)
