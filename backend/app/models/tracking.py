from sqlalchemy import Column, Integer, String, Float, DateTime, Text
from sqlalchemy.sql import func
from app.core.database import Base


class TrackingPackage(Base):
    """物流包裹主表"""
    __tablename__ = 'tracking_package'

    id = Column(Integer, primary_key=True, autoincrement=True)
    package_no = Column(String(64), unique=True, nullable=False, comment='包裹号')
    order_no = Column(String(64), comment='订单号')
    batch_no = Column(String(64), comment='批次号')
    product_name = Column(String(256), comment='品名')
    sku_code = Column(String(64), comment='SKU编码')
    qty = Column(Integer, default=0, comment='数量')
    weight_kg = Column(Float, default=0, comment='重量(kg)')
    sender = Column(String(128), comment='发件方')
    receiver = Column(String(128), comment='收件方')
    receiver_phone = Column(String(20), comment='收件人电话')
    receiver_address = Column(String(256), comment='收件地址')
    current_node = Column(String(64), comment='当前节点')
    current_status = Column(Integer, default=0, comment='状态:0待集货1运输中2报关中3清关中4配送中5已签收')
    create_time = Column(DateTime, server_default=func.now())
    update_time = Column(DateTime, server_default=func.now(), onupdate=func.now())
    deleted = Column(Integer, default=0)


class TrackingLog(Base):
    """物流追踪日志表"""
    __tablename__ = 'tracking_log'

    id = Column(Integer, primary_key=True, autoincrement=True)
    package_no = Column(String(64), nullable=False, comment='包裹号')
    node_name = Column(String(64), comment='节点名称')
    node_order = Column(Integer, default=0, comment='节点顺序')
    operator = Column(String(64), comment='操作人')
    location = Column(String(128), comment='地点')
    description = Column(Text, comment='描述')
    status = Column(Integer, default=0, comment='状态:0进行中1已完成')
    operate_time = Column(DateTime, comment='操作时间')
    create_time = Column(DateTime, server_default=func.now())
