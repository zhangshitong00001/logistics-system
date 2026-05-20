from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from sqlalchemy import func
from app.core.database import get_db
from app.models.transport import TransportVehicle, TransportTask

router = APIRouter(prefix="/api/v1/transport", tags=["装车运输管理"])


@router.get("/dashboard")
def get_dashboard(db: Session = Depends(get_db)):
    """运输仪表盘"""
    in_transit = db.query(func.count(TransportTask.id)).filter(
        TransportTask.status == 1, TransportTask.deleted == 0,
    ).scalar() or 0

    today_departed = db.query(func.count(TransportTask.id)).filter(
        func.date(TransportTask.departure_time) == func.current_date(),
        TransportTask.deleted == 0,
    ).scalar() or 0

    today_arrived = db.query(func.count(TransportTask.id)).filter(
        func.date(TransportTask.actual_arrival) == func.current_date(),
        TransportTask.deleted == 0,
    ).scalar() or 0

    anomalies = db.query(func.count(TransportTask.id)).filter(
        TransportTask.status == 4, TransportTask.deleted == 0,
    ).scalar() or 0

    total = today_departed + today_arrived + anomalies
    ontime_rate = round(today_arrived / (today_departed + 1) * 100, 1) if today_departed > 0 else 0

    return {
        "code": 200,
        "data": {
            "in_transit": in_transit,
            "today_departed": today_departed,
            "today_arrived": today_arrived,
            "anomalies": anomalies,
            "ontime_rate": ontime_rate,
        }
    }


@router.get("/vehicle")
def get_vehicles(
    page: int = Query(1, ge=1),
    size: int = Query(20, ge=1, le=100),
    status: int = -1,
    db: Session = Depends(get_db),
):
    """车辆列表"""
    q = db.query(TransportVehicle).filter(TransportVehicle.deleted == 0)
    if status >= 0:
        q = q.filter(TransportVehicle.status == status)

    total = q.count()
    records = q.order_by(TransportVehicle.create_time.desc())\
                .offset((page - 1) * size).limit(size).all()

    return {
        "code": 200,
        "data": {
            "records": [{
                "id": r.id, "plate_no": r.plate_no, "vehicle_type": r.vehicle_type,
                "driver_name": r.driver_name, "driver_phone": r.driver_phone,
                "max_weight": r.max_weight, "max_volume": r.max_volume,
                "longitude": r.longitude, "latitude": r.latitude,
                "status": r.status,
            } for r in records],
            "total": total, "page": page, "size": size,
            "pages": (total + size - 1) // size,
        }
    }


@router.get("/vehicle/positions")
def get_vehicle_positions(db: Session = Depends(get_db)):
    """获取所有车辆实时位置"""
    vehicles = db.query(TransportVehicle).filter(
        TransportVehicle.deleted == 0,
        TransportVehicle.status.in_([1, 2]),
    ).all()

    return {
        "code": 200,
        "data": [{
            "id": v.id, "plate_no": v.plate_no,
            "longitude": v.longitude, "latitude": v.latitude,
            "speed": v.speed, "status": v.status,
        } for v in vehicles],
    }


@router.get("/task")
def get_tasks(
    page: int = Query(1, ge=1),
    size: int = Query(20, ge=1, le=100),
    status: int = -1,
    db: Session = Depends(get_db),
):
    """运输任务列表"""
    q = db.query(TransportTask).filter(TransportTask.deleted == 0)
    if status >= 0:
        q = q.filter(TransportTask.status == status)

    total = q.count()
    records = q.order_by(TransportTask.create_time.desc())\
                .offset((page - 1) * size).limit(size).all()

    return {
        "code": 200,
        "data": {
            "records": [{
                "id": r.id, "task_no": r.task_no,
                "vehicle_id": r.vehicle_id, "route_from": r.route_from,
                "route_to": r.route_to, "batch_no": r.batch_no,
                "driver_name": r.driver_name, "status": r.status,
                "departure_time": str(r.departure_time) if r.departure_time else None,
                "estimated_arrival": str(r.estimated_arrival) if r.estimated_arrival else None,
            } for r in records],
            "total": total, "page": page, "size": size,
            "pages": (total + size - 1) // size,
        }
    }


@router.post("/task")
def create_task(
    vehicle_id: int = 0,
    route_from: str = "",
    route_to: str = "",
    batch_no: str = "",
    driver_name: str = "",
    driver_phone: str = "",
    db: Session = Depends(get_db),
):
    """创建运输任务"""
    import uuid
    task_no = f"TT-{uuid.uuid4().hex[:8].upper()}"

    task = TransportTask(
        task_no=task_no,
        vehicle_id=vehicle_id if vehicle_id else None,
        route_from=route_from,
        route_to=route_to,
        batch_no=batch_no,
        driver_name=driver_name,
        driver_phone=driver_phone,
        status=0,
    )
    db.add(task)
    db.commit()

    return {"code": 200, "data": {"task_id": task.id, "task_no": task_no}}


@router.put("/task/{task_id}/status")
def update_task_status(task_id: int, status: int = 0, db: Session = Depends(get_db)):
    """更新运输任务状态"""
    task = db.query(TransportTask).filter(
        TransportTask.id == task_id, TransportTask.deleted == 0,
    ).first()
    if not task:
        return {"code": 404, "message": "任务不存在"}

    task.status = status
    db.commit()
    return {"code": 200, "message": "状态更新成功"}
