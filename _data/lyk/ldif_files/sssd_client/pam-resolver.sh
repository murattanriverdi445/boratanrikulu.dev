#!/bin/bash

cd /etc/pam.d
cp -a common-account common-account.orig
cat <<'EOF'> common-account
#
# /etc/pam.d/common-account - authorization settings common to all services
#
account [success=1 new_authtok_reqd=done default=ignore]  pam_unix.so
# here's the fallback if no module succeeds
account requisite                       pam_deny.so
# prime the stack with a positive return value if there isn't one already;
# this avoids us returning an error just because nothing sets a success code
# since the modules above will each just jump around
account required                        pam_permit.so
# and here are more per-package modules (the "Additional" block)
session optional      pam_mkhomedir.so skel=/etc/skel umask=0077
account [default=bad success=ok user_unknown=ignore]    pam_sss.so
EOF

cp -a common-auth common-auth.orig
cat <<'EOF'> common-auth
#
# /etc/pam.d/common-auth - authentication settings common to all services
#
# here are the per-package modules (the "Primary" block)
auth    [success=2 default=ignore]                      pam_sss.so
auth    [success=1 default=ignore]      pam_unix.so nullok_secure try_first_pass
# here's the fallback if no module succeeds
auth    requisite                       pam_deny.so
# prime the stack with a positive return value if there isn't one already;
# this avoids us returning an error just because nothing sets a success code
# since the modules above will each just jump around
auth    required                        pam_permit.so
# and here are more per-package modules (the "Additional" block)
EOF

cp -a common-password common-password.orig
cat <<'EOF'> common-password
#
# /etc/pam.d/common-password - password-related modules common to all services
# here are the per-package modules (the "Primary" block)
password        sufficient                      pam_sss.so
password        [success=1 default=ignore]      pam_unix.so obscure try_first_pass sha512
# here's the fallback if no module succeeds
password        requisite                       pam_deny.so
# prime the stack with a positive return value if there isn't one already;
# this avoids us returning an error just because nothing sets a success code
# since the modules above will each just jump around
password        required                        pam_permit.so
# and here are more per-package modules (the "Additional" block)
EOF

cp -a common-session common-session.orig
cat <<'EOF'> common-session
#
# /etc/pam.d/common-session - session-related modules common to all services
#
# here are the per-package modules (the "Primary" block)
session [default=1]   pam_permit.so
# here's the fallback if no module succeeds
session requisite     pam_deny.so
# prime the stack with a positive return value if there isn't one already;
# this avoids us returning an error just because nothing sets a success code
# since the modules above will each just jump around
session required      pam_permit.so
# and here are more per-package modules (the "Additional" block)
session optional      pam_mkhomedir.so skel=/etc/skel umask=0077
session optional      pam_sss.so
session required      pam_unix.so
EOF
