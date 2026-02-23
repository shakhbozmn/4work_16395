from django.core.management import call_command
from django.core.management.base import BaseCommand
from django.db import transaction


class Command(BaseCommand):
    help = "Load demo data including categories, skills, and sample projects"

    def handle(self, *args, **options):
        self.stdout.write(self.style.SUCCESS("Loading demo data..."))

        try:
            with transaction.atomic():
                self.stdout.write("Loading categories...")
                call_command("loaddata", "fixtures/categories.json")
                self.stdout.write(self.style.SUCCESS("Categories loaded successfully"))

                self.stdout.write("Loading skills...")
                call_command("loaddata", "fixtures/skills.json")
                self.stdout.write(self.style.SUCCESS("Skills loaded successfully"))

                self.stdout.write("Loading demo data...")
                call_command("loaddata", "fixtures/demo_data.json")
                self.stdout.write(self.style.SUCCESS("Demo data loaded successfully"))

            self.stdout.write(
                self.style.SUCCESS("\nAll demo data loaded successfully!")
            )
            self.stdout.write("\nDemo accounts:")
            self.stdout.write("Client: john_client / password123")
            self.stdout.write("Freelancer 1: jane_freelancer / password123")
            self.stdout.write("Freelancer 2: bob_freelancer / password123")

        except Exception as e:
            self.stdout.write(self.style.ERROR(f"\nError loading demo data: {str(e)}"))
            raise
