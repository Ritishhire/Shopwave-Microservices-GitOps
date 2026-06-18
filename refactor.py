import os
import shutil

# Dirs
base_dir = "helm/base/templates"
mongo_dir = "helm/mongo/templates"
backend_dir = "helm/backend/templates"
frontend_dir = "helm/frontend/templates"

os.makedirs(base_dir, exist_ok=True)
os.makedirs(mongo_dir, exist_ok=True)
os.makedirs(backend_dir, exist_ok=True)
os.makedirs(frontend_dir, exist_ok=True)

# Copy _helpers.tpl
helpers = "helm/shopwave/templates/_helpers.tpl"
if os.path.exists(helpers):
    shutil.copy(helpers, base_dir)
    shutil.copy(helpers, mongo_dir)
    shutil.copy(helpers, backend_dir)
    shutil.copy(helpers, frontend_dir)

# Move templates
def move_if_exists(src, dst):
    if os.path.exists(src):
        for item in os.listdir(src):
            s = os.path.join(src, item)
            d = os.path.join(dst, item)
            if os.path.isdir(s):
                shutil.move(s, d)
            else:
                shutil.copy(s, d)

move_if_exists("helm/shopwave/templates/configmap", base_dir)
move_if_exists("helm/shopwave/templates/ingress", base_dir)
if os.path.exists("helm/shopwave/templates/namespace.yaml"):
    shutil.copy("helm/shopwave/templates/namespace.yaml", base_dir)

move_if_exists("helm/shopwave/templates/mongodb", mongo_dir)
move_if_exists("helm/shopwave/templates/backend", backend_dir)
move_if_exists("helm/shopwave/templates/frontend", frontend_dir)

print("Refactor complete")
