FROM jeanblanchard/alpine-glibc:3.19

ENV \
   # container/su-exec UID \
   EUID=1001 \
   # container/su-exec GID \
   EGID=1001 \
   # container/su-exec user name \
   EUSER=docker-user \
   # container/su-exec group name \
   EGROUP=docker-group \
   # container user home dir \
   EHOME= \
   # should user created/updated to use nologin shell? (yes/no) \
   ENOLOGIN=yes \
   # should user home dir get chown'ed? (yes/no) \
   ECHOWNHOME=no \
   # additional directories to create + chown (space separated) \
   ECHOWNDIRS= \
   # additional files to create + chown (space separated) \
   ECHOWNFILES= \
   # container timezone \
   TZ=UTC

# Install shadow (for usermod and groupmod) and su-exec
RUN \
   apk --no-cache --update add \
   shadow \
   su-exec \
   tzdata

COPY \
   chown-path \
   set-user-group-home \
   entrypoint-crond \
   entrypoint-exec \
   entrypoint-su-exec \
   /usr/bin/

RUN \
   chmod +x \
   /usr/bin/chown-path \
   /usr/bin/set-user-group-home \
   /usr/bin/entrypoint-crond \
   /usr/bin/entrypoint-exec \
   /usr/bin/entrypoint-su-exec

ENV \
   # container/su-exec UID \
   EUID=1001 \
   # container/su-exec GID \
   EGID=1001 \
   # container/su-exec user name \
   EUSER=vscode \
   # container/su-exec group name \
   EGROUP=vscode \
   # should user shell set to nologin? (yes/no) \
   ENOLOGIN=no \
   # container user home dir \
   EHOME=/home/vscode \
   # code-server version \
   VERSION=4.22.1

COPY code-server /usr/bin/
RUN chmod +x /usr/bin/code-server

# Install dependencies
RUN \
   apk --no-cache --update add \
   bash \
   curl \
   git \
   gnupg \
   nodejs \
   openssh-client \
   npm

RUN \
   wget https://github.com/cdr/code-server/releases/download/v$VERSION/code-server-$VERSION-linux-amd64.tar.gz && \
   tar x -zf code-server-$VERSION-linux-amd64.tar.gz && \
   rm code-server-$VERSION-linux-amd64.tar.gz && \
   mv code-server-$VERSION-linux-amd64 /usr/lib/code-server

ENTRYPOINT ["entrypoint-su-exec", "code-server"]
CMD ["--bind-addr 0.0.0.0:8080"]
