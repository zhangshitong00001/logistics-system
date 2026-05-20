from sqlalchemy import Column, Integer, String, Float, DateTime, Text, ForeignKey
from sqlalchemy.sql import func
from app.core.database import Base


class TransportVehicle(Base):
    """车辆表"""
    __tablename__ = 'transport_vehicle'

    id = Column(Integer, primary_key=True, autoincrement=True)
    plate_no = Column(String(32), unique=True, nullable=False, comment='车牌号')
    vehicle_type = Column(String(32), comment='车型')
    driver_name = Column(String(64), comment='司机姓名')
    driver_phone = Column(String(20), comment='司机电话')
    max_weight = Column(Float, comment='最大载重(kg)')
    max_volume = Column(Float, comment='最大容积(m³)')
    longitude = Column(Float, default=0, comment='经度')
    latitude = Column(Float, default=0, comment='纬度')
    speed = Column(Float, default=0, comment='速度(km/h)')
    status = Column(Integer, default=1, comment='状态:1空闲2运输中3维修')
    create_time = Column(DateTime, server_default=func.now())
    update_time = Column(DateTime, server_default=func.now(), onupdate=func.now())
    deleted = Column(Integer, default=0)


class TransportTask(Base):
    """运输任务表"""
    __tablename__ = 'transport_task'

    id = Column(Integer, primary_key=True, autoincrement=True)
    task_no = Column(String(64), unique=True, nullable=False, comment='任务编号')
    vehicle_id = Column(Integer, ForeignKey('transport_vehicle.id'), comment='车辆ID')
    route_from = Column(String(128), comment='出发地')
    route_to = Column(String(128), comment='目的地')
    departure_time = Column(DateTime, comment='出发时间')
    estimated_arrival = Column(DateTime, comment='预计到达')
    actual_arrival = Column(DateTime, comment='实际到达')
    batch_no = Column(String(64), comment='关联批次号')
    driver_name = Column(String(64), comment='司机')
    driver_phone = Column(String(20), comment='司机电话')
    status = Column(Integer, default=0, comment='状态:0待发车1运输中2已到达3已完成4异常')
    remark = Column(Text, comment='备注')
    create_time = Column(DateTime, server_default=func.now())
    update_time = Column(DateTime, server_default=func.now(), onupdate=func.now())
    deleted = Column(Integer, default=0)
