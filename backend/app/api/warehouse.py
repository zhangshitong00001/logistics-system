from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from sqlalchemy import func
from app.core.database import get_db
from app.models.warehouse_sorting import WarehouseSortingTask

router = APIRouter(prefix="/api/v1/warehouse", tags=["仓库分拣管理"])


@router.get("/dashboard")
def get_dashboard(db: Session = Depends(get_db)):
    """分拣仪表盘"""
    pending = db.query(func.count(WarehouseSortingTask.id)).filter(
        WarehouseSortingTask.status == 0, WarehouseSortingTask.deleted == 0,
    ).scalar() or 0

    in_progress = db.query(func.count(WarehouseSortingTask.id)).filter(
        WarehouseSortingTask.status == 1, WarehouseSortingTask.deleted == 0,
    ).scalar() or 0

    completed = db.query(func.count(WarehouseSortingTask.id)).filter(
        WarehouseSortingTask.status == 2, WarehouseSortingTask.deleted == 0,
    ).scalar() or 0

    total = pending + in_progress + completed
    accuracy = round(completed / (total + 1) * 100, 1)

    return {
        "code": 200,
        "data": {
            "pending": pending, "in_progress": in_progress,
            "completed": completed, "accuracy": accuracy,
        }
    }


@router.get("/sorting-task")
def get_sorting_tasks(
    page: int = Query(1, ge=1),
    size: int = Query(20, ge=1, le=100),
    status: int = -1,
    db: Session = Depends(get_db),
):
    """分拣任务列表"""
    q = db.query(WarehouseSortingTask).filter(WarehouseSortingTask.deleted == 0)
    if status >= 0:
        q = q.filter(WarehouseSortingTask.status == status)

    total = q.count()
    records = q.order_by(WarehouseSortingTask.create_time.desc())\
                .offset((page - 1) * size).limit(size).all()

    return {
        "code": 200,
        "data": {
            "records": [{
                "id": r.id, "task_no": r.task_no, "batch_no": r.batch_no,
                "sku_code": r.sku_code, "product_name": r.product_name,
                "total_qty": r.total_qty, "sorted_qty": r.sorted_qty,
                "location": r.location, "assignee": r.assignee, "status": r.status,
            } for r in records],
            "total": total, "page": page, "size": size,
            "pages": (total + size - 1) // size,
        }
    }


@router.get("/kanban")
def get_kanban(db: Session = Depends(get_db)):
    """获取分拣看板数据（3列）"""
    pending = db.query(WarehouseSortingTask).filter(
        WarehouseSortingTask.status == 0, WarehouseSortingTask.deleted == 0,
    ).order_by(WarehouseSortingTask.create_time.desc()).limit(20).all()

    in_progress = db.query(WarehouseSortingTask).filter(
        WarehouseSortingTask.status == 1, WarehouseSortingTask.deleted == 0,
    ).order_by(WarehouseSortingTask.create_time.desc()).limit(20).all()

    completed = db.query(WarehouseSortingTask).filter(
        WarehouseSortingTask.status == 2, WarehouseSortingTask.deleted == 0,
    ).order_by(WarehouseSortingTask.update_time.desc()).limit(20).all()

    def fmt(tasks):
        return [{
            "id": t.id, "task_no": t.task_no, "batch_no": t.batch_no,
            "product_name": t.product_name, "total_qty": t.total_qty,
            "sorted_qty": t.sorted_qty, "assignee": t.assignee,
        } for t in tasks]

    return {
        "code": 200,
        "data": {
            "pending": fmt(pending),
            "in_progress": fmt(in_progress),
            "completed": fmt(completed),
        }
    }


@router.put("/sorting-task/{task_id}/start")
def start_sorting(task_id: int, assignee: str = "", db: Session = Depends(get_db)):
    """开始分拣"""
    task = db.query(WarehouseSortingTask).filter(
        WarehouseSortingTask.id == task_id, WarehouseSortingTask.deleted == 0,
    ).first()
    if not task:
        return {"code": 404, "message": "任务不存在"}

    task.status = 1
    if assignee:
        task.assignee = assignee
    db.commit()

    return {"code": 200, "message": "已开始分拣"}


@router.put("/sorting-task/{task_id}/complete")
def complete_sorting(task_id: int, sorted_qty: int = 0, db: Session = Depends(get_db)):
    """完成分拣"""
    task = db.query(WarehouseSortingTask).filter(
        WarehouseSortingTask.id == task_id, WarehouseSortingTask.deleted == 0,
    ).first()
    if not task:
        return {"code": 404, "message": "任务不存在"}

    task.status = 2
    task.sorted_qty = sorted_qty
    db.commit()

    return {"code": 200, "message": "分拣完成"}
