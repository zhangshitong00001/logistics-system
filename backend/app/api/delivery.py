from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from sqlalchemy import func
from app.core.database import get_db
from app.models.delivery import DeliveryTask
from app.models.sorting import PickupPoint

router = APIRouter(prefix="/api/v1/delivery", tags=["配送管理"])


@router.get("/dashboard")
def get_dashboard(db: Session = Depends(get_db)):
    """配送仪表盘"""
    in_delivery = db.query(func.count(DeliveryTask.id)).filter(
        DeliveryTask.status == 1, DeliveryTask.deleted == 0,
    ).scalar() or 0

    today_completed = db.query(func.count(DeliveryTask.id)).filter(
        DeliveryTask.status == 2,
        func.date(DeliveryTask.update_time) == func.current_date(),
        DeliveryTask.deleted == 0,
    ).scalar() or 0

    anomalies = db.query(func.count(DeliveryTask.id)).filter(
        DeliveryTask.status == 3, DeliveryTask.deleted == 0,
    ).scalar() or 0

    total = in_delivery + today_completed + anomalies
    rate = round(today_completed / (total + 1) * 100, 1)

    return {
        "code": 200,
        "data": {
            "in_delivery": in_delivery,
            "today_completed": today_completed,
            "anomalies": anomalies,
            "completion_rate": rate,
        }
    }


@router.get("/task")
def get_tasks(
    page: int = Query(1, ge=1),
    size: int = Query(20, ge=1, le=100),
    status: int = -1,
    db: Session = Depends(get_db),
):
    """配送任务列表"""
    q = db.query(DeliveryTask).filter(DeliveryTask.deleted == 0)
    if status >= 0:
        q = q.filter(DeliveryTask.status == status)

    total = q.count()
    records = q.order_by(DeliveryTask.create_time.desc())\
                .offset((page - 1) * size).limit(size).all()

    return {
        "code": 200,
        "data": {
            "records": [{
                "id": r.id, "task_no": r.task_no,
                "pickup_point_id": r.pickup_point_id,
                "package_count": r.package_count, "batch_no": r.batch_no,
                "delivery_person": r.delivery_person, "status": r.status,
            } for r in records],
            "total": total, "page": page, "size": size,
            "pages": (total + size - 1) // size,
        }
    }


@router.post("/task")
def create_task(
    pickup_point_id: int = 0,
    package_count: int = 0,
    batch_no: str = "",
    delivery_person: str = "",
    db: Session = Depends(get_db),
):
    """生成配送任务"""
    import uuid
    task_no = f"PS-{uuid.uuid4().hex[:8].upper()}"

    task = DeliveryTask(
        task_no=task_no,
        pickup_point_id=pickup_point_id if pickup_point_id else None,
        package_count=package_count,
        batch_no=batch_no,
        delivery_person=delivery_person,
        status=0,
    )
    db.add(task)
    db.commit()

    return {"code": 200, "data": {"task_id": task.id, "task_no": task_no}}


@router.put("/task/{task_id}/status")
def update_status(task_id: int, status: int = 0, db: Session = Depends(get_db)):
    """更新配送状态"""
    task = db.query(DeliveryTask).filter(
        DeliveryTask.id == task_id, DeliveryTask.deleted == 0,
    ).first()
    if not task:
        return {"code": 404, "message": "任务不存在"}
    task.status = status
    db.commit()
    return {"code": 200, "message": "状态更新成功"}
