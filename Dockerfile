ARG BUILD_IMAGE=mcr.microsoft.com/windows/servercore:1809
ARG FROM_IMAGE=mcr.microsoft.com/windows/servercore:1809

FROM $BUILD_IMAGE as build

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ARG OTP_VERSION
ARG OTP_HASH

ADD https://github.com/erlang/otp/releases/download/OTP-${OTP_VERSION}/otp_win64_${OTP_VERSION}.exe ./otp-installer.exe

RUN if ((Get-FileHash ".\otp-installer.exe" -Algorithm SHA256).Hash -ne $Env:OTP_HASH) { exit 1; }

FROM $FROM_IMAGE

ARG OTP_VERSION

# run OTP installer in this image, copying Program Files over doesn't work
COPY --from=build ["C:/otp-installer.exe", "C:/otp-installer.exe"]

RUN .\otp-installer.exe /S /w /v"/qn"

RUN del /f .\otp-installer.exe

# This is a workaround for nanoserver where not possible to set PATH using setx or similar
ENV PATH="C:\Windows\system32;C:\Windows;C:/Program Files/erl-${OTP_VERSION}/bin"

# Some failed attempts below; someone could fix these!
# RUN setx /M PATH "%PATH%;%ProgramFiles%\erl-%OTP_VERSION%\bin"
# RUN setx /M PATH $($Env:PATH + ';C:\Program Files\erl-' + $Env:OTP_VERSION + '\bin')

CMD [ "erl.exe" ]
