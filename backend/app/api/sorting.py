from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from sqlalchemy import func
from app.core.database import get_db
from app.models.sorting import SortingTask, PickupPoint

router = APIRouter(prefix="/api/v1/sorting", tags=["收件点分装管理"])


@router.get("/dashboard")
def get_dashboard(db: Session = Depends(get_db)):
    """分装仪表盘"""
    pending = db.query(func.count(SortingTask.id)).filter(
        SortingTask.status == 0, SortingTask.deleted == 0,
    ).scalar() or 0

    completed = db.query(func.count(SortingTask.id)).filter(
        SortingTask.status == 2, SortingTask.deleted == 0,
    ).scalar() or 0

    total_points = db.query(func.count(PickupPoint.id)).filter(
        PickupPoint.deleted == 0,
    ).scalar() or 0

    covered = db.query(func.count(PickupPoint.id)).filter(
        PickupPoint.coverage_status == 1, PickupPoint.deleted == 0,
    ).scalar() or 0

    workers = db.query(SortingTask.assignee).filter(
        SortingTask.deleted == 0, SortingTask.assignee.isnot(None),
    ).distinct().count()

    total = pending + completed
    rate = round(completed / total * 100, 1) if total > 0 else 0

    return {
        "code": 200,
        "data": {
            "pending": pending,
            "completed": completed,
            "completion_rate": rate,
            "worker_count": workers,
            "total_points": total_points,
            "covered_points": covered,
        }
    }


@router.get("/task")
def get_tasks(
    page: int = Query(1, ge=1),
    size: int = Query(20, ge=1, le=100),
    status: int = -1,
    db: Session = Depends(get_db),
):
    """分装任务列表"""
    q = db.query(SortingTask).filter(SortingTask.deleted == 0)
    if status >= 0:
        q = q.filter(SortingTask.status == status)

    total = q.count()
    records = q.order_by(SortingTask.create_time.desc())\
                .offset((page - 1) * size).limit(size).all()

    return {
        "code": 200,
        "data": {
            "records": [{
                "id": r.id,
                "task_no": r.task_no,
                "batch_no": r.batch_no,
                "product_name": r.product_name,
                "total_qty": r.total_qty,
                "completed_qty": r.completed_qty,
                "target_point_id": r.target_point_id,
                "priority": r.priority,
                "assignee": r.assignee,
                "status": r.status,
            } for r in records],
            "total": total,
            "page": page,
            "size": size,
            "pages": (total + size - 1) // size,
        }
    }


@router.post("/task")
def create_task(
    batch_no: str = "",
    sku_code: str = "",
    product_name: str = "",
    total_qty: int = 0,
    target_point_id: int = 0,
    priority: int = 0,
    assignee: str = "",
    db: Session = Depends(get_db),
):
    """创建分装任务"""
    import uuid
    task_no = f"ST-{uuid.uuid4().hex[:8].upper()}"

    task = SortingTask(
        task_no=task_no,
        batch_no=batch_no,
        sku_code=sku_code,
        product_name=product_name,
        total_qty=total_qty,
        target_point_id=target_point_id if target_point_id else None,
        priority=priority,
        assignee=assignee,
        status=0,
    )
    db.add(task)
    db.commit()

    return {"code": 200, "data": {"task_id": task.id, "task_no": task_no}}


@router.put("/task/{task_id}/execute")
def execute_task(task_id: int, completed_qty: int = 0, db: Session = Depends(get_db)):
    """执行分装"""
    task = db.query(SortingTask).filter(
        SortingTask.id == task_id, SortingTask.deleted == 0,
    ).first()
    if not task:
        return {"code": 404, "message": "任务不存在"}

    task.completed_qty = completed_qty
    task.status = 2 if completed_qty >= task.total_qty else 1
    db.commit()

    return {"code": 200, "message": "更新成功"}
