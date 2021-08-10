from django.shortcuts import render
from .forms import main_form


def main_view(request):
    context = {}
    context['form'] = main_form()
    return render(request, "index.html", context)