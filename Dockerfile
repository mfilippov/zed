FROM ubuntu:24.10

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Yerevan
ENV PATH="/root/.cargo/bin:$PATH"
ENV ZED_BUNDLE=true

WORKDIR /build

RUN apt update
RUN apt dist-upgrade -y
RUN apt install -y wget mold
RUN wget -O /rustup-init "https://static.rust-lang.org/rustup/dist/x86_64-unknown-linux-gnu/rustup-init"
RUN chmod +x /rustup-init
RUN /rustup-init -y --profile default
COPY script/linux /install-deps
RUN /install-deps
RUN rm /rustup-init /install-deps

RUN cat <<EOF > /build.sh
#!/bin/bash
/build/script/generate-licenses
cargo build --release --package zed --package cli
EOF
RUN chmod +x /build.sh


CMD [ "/build.sh" ]

#How to run it:
# clone repo
# cd zed
# sudo docker build -t zed-builder .
# sudo docker run -v .:/build zed-builder
# sudo cp target/release/zed /usr/libexec/zed-editor
# sudo cp target/release/cli /usr/bin/zed
# sudo mkdir -p /usr/share/icons/hicolor/512x512/apps
# sudo cp crates/zed/resources/app-icon$suffix.png /usr/share/icons/hicolor/512x512/apps/zed.png
# sudo mkdir -p /usr/share/icons/hicolor/1024x1024/apps
# sudo cp crates/zed/resources/app-icon$suffix@2x.png /usr/share/icons/hicolor/1024x1024/apps/zed.png
# DO_STARTUP_NOTIFY=true APP_CLI=zed APP_ICON=zed APP_ARGS='%U' APP_NAME=Zed envsubst < crates/zed/resources/zed.desktop.in | sudo tee /usr/share/applications/zed.desktop > /dev/null
