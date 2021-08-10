from django.urls import path
  
# importing views from views..py
from .views import main_view
  
urlpatterns = [
    path('', main_view),
]