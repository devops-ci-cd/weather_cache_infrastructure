from django import forms
from .widgets import BootstrapDateTimePickerInput
from datetime import datetime


class main_form(forms.Form):
    options = {
        'input_formats': ['%d.%m.%Y'],
        'widget': BootstrapDateTimePickerInput(),
        'initial': datetime.today().strftime('%d.%m.%Y'),
    }
    date_from = forms.DateField(**options)
    date_to = forms.DateField(**options)
    city = forms.CharField(initial='St. Petersburg')