from django.apps import apps
from django.http import JsonResponse


def key_values_columns(request):
    table_name = request.GET.get("table_name", "").strip()
    if not table_name or table_name == "key_values":
        return JsonResponse({"columns": []})

    for model in apps.get_models():
        if getattr(model._meta, "db_table", None) == table_name:
            columns = [
                field.name
                for field in model._meta.fields
                if (not field.auto_created or field.concrete) and not field.name.endswith("_id")
            ]
            return JsonResponse({"columns": columns})

    return JsonResponse({"columns": []})
