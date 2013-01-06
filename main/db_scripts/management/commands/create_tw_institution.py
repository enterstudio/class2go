from django.core.management.base import BaseCommand, CommandError
from c2g.models import Institution

#from django.contrib.sites.models import Site


class Command(BaseCommand):
    help = "Run this command on initial setup of an instance to create the TW institution."

    def handle(self, *args, **options):
        institution = Institution(
                                  title = "ThoughtWorks",
                                  country = "China",
                                  city = "Xi'an",
                                  domains = "thoughtworks.com")
                                  
        institution.save()
        print "Institution created successfully"
            
