from django.contrib import admin
from django.db import models

from . import models as app_models


class InspectDBAdmin(admin.ModelAdmin):
    """Generic admin configuration for inspectdb-generated models."""

    def __init__(self, model, admin_site):
        super().__init__(model, admin_site)
        self.list_display = self._build_list_display(model)
        self.search_fields = self._build_search_fields(model)
        self.list_filter = self._build_list_filter(model)
        self.ordering = self._build_ordering(model)

    @staticmethod
    def _build_list_display(model):
        fields = [
            field.name
            for field in model._meta.fields
            if not field.is_relation or field.many_to_one or field.one_to_one
        ]
        return tuple(fields[:8]) or ("pk",)

    @staticmethod
    def _build_search_fields(model):
        searchable_types = (models.CharField, models.TextField, models.EmailField, models.SlugField)
        return tuple(
            field.name
            for field in model._meta.fields
            if isinstance(field, searchable_types)
        )

    @staticmethod
    def _build_list_filter(model):
        filterable_types = (
            models.BooleanField,
            models.DateField,
            models.DateTimeField,
            models.IntegerField,
            models.ForeignKey,
        )
        return tuple(
            field.name
            for field in model._meta.fields
            if isinstance(field, filterable_types)
        )

    @staticmethod
    def _build_ordering(model):
        if any(field.name == "id" for field in model._meta.fields):
            return ("id",)
        if model._meta.fields:
            return (model._meta.fields[0].name,)
        return ()


def register_model(model):
    """Register inspectdb-generated models with a generic admin class."""
    if model._meta.abstract or model._meta.proxy:
        return model
    if model._meta.app_label != app_models.__package__.split(".")[-1]:
        return model
    try:
        admin.site.register(model, InspectDBAdmin)
    except admin.sites.AlreadyRegistered:
        pass
    return model


for _model in app_models.__dict__.values():
    if isinstance(_model, type) and issubclass(_model, models.Model) and _model is not models.Model:
        register_model(_model)
