FROM alpine AS marks-builder

WORKDIR /src
COPY ./ ./

RUN apk --no-cache add chicken openssl openssl-dev openssl-libs-static make sudo
RUN make clean \
  && make CHICKEN_CSC=csc eggs \
  && make CHICKEN_CSC=csc

FROM alpine
WORKDIR /marks
COPY --from=marks-builder /src/marks ./

ENTRYPOINT ["./marks"]
