from functools import lru_cache
from typing import Optional

from fastapi import APIRouter

from backend.service.dictionary_service import DictionaryService

router = APIRouter(prefix="/meta", tags=["meta"])


@lru_cache
def get_dictionary_svc() -> DictionaryService:
    return DictionaryService()


@router.get("/dictionaries")
async def dictionaries(locale: Optional[str] = None):
    return get_dictionary_svc().all(locale)


@router.get("/dictionaries/{name}")
async def dictionary(name: str, locale: Optional[str] = None):
    return get_dictionary_svc().one(name, locale)
