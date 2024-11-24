# syntax=docker/dockerfile:1.0.0-experimental

FROM ubuntu:24.04

RUN apt update && apt install -y dotnet-sdk-8.0

RUN mkdir /home/ubuntu/Blesonite/

COPY --from=Headless . /home/ubuntu/Blesonite/Headless

COPY ./src/Blue /home/ubuntu/Blesonite/Blue

WORKDIR /home/ubuntu/Blesonite/Blue

RUN dotnet build

FROM scratch

COPY --from=0 /home/ubuntu/Blesonite/Blue/bin/Debug/net8.0/Blue.dll ./Blue.dll