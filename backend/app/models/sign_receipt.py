from sqlalchemy import Column, Integer, String, DateTime, Text, ForeignKey
from sqlalchemy.sql import func
from app.core.database import Base


class SignReceipt(Base):
    """签收记录表"""
    __tablename__ = 'sign_receipt'

    id = Column(Integer, primary_key=True, autoincrement=True)
    receipt_no = Column(String(64), unique=True, nullable=False, comment='签收单号')
    package_no = Column(String(64), nullable=False, comment='包裹号')
    delivery_task_id = Column(Integer, ForeignKey('delivery_task.id'), comment='配送任务ID')
    pickup_point_id = Column(Integer, ForeignKey('pickup_point.id'), comment='收件点ID')
    sign_result = Column(String(16), comment='签收结果:normal正常/damaged破损/shortage短缺/refused拒收')
    signer = Column(String(64), comment='签收人')
    sign_time = Column(DateTime, comment='签收时间')
    signature_image = Column(Text, comment='电子签名(Base64)')
    evidence_image = Column(Text, comment='凭证照片(Base64)')
    inbound_status = Column(Integer, default=0, comment='入库状态:0未入库1已入库')
    remark = Column(Text, comment='备注')
    create_time = Column(DateTime, server_default=func.now())
    update_time = Column(DateTime, server_default=func.now(), onupdate=func.now())
    deleted = Column(Integer, default=0)
