#!/usr/bin/env python
#
# Use Django's template machinery to expand static web pages.  First
# tries the default template path for a particular installation, then
# looks for templates in the filesystem.

from django.template import Context, Engine, TemplateDoesNotExist
from django.template.loader import get_template
from django.conf import settings
import rwh.settings
import sys

settings.configure(rwh.settings)
c = Context()

if len(sys.argv) == 2:
    in_name = sys.argv[1]
    out_name = 'stdout'
    out_fp = sys.stdout
elif len(sys.argv) == 3:
    in_name = sys.argv[1]
    out_name = sys.argv[2]
    out_fp = None
else:
    print('Usage: %s template-file [output-file]' % sys.argv[0], file=sys.stderr)
    sys.exit(1)
    
try:
    t = Engine().get_template(in_name)
except TemplateDoesNotExist:
    t = Engine().from_string(template_code=open(in_name).read())
if out_fp is None:
    out_fp = open(out_name, 'w')
out_fp.write(t.render(c))
out_fp.close()
