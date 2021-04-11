FROM alpine AS marks-builder

WORKDIR /src
COPY ./ ./

RUN apk --no-cache add chicken openssl openssl-dev openssl-libs-static make
RUN chicken-install srfi-1 linenoise openssl http-client
RUN make clean \
  && make CHICKEN_CSC=csc \
  && make CHICKEN_CSC=csc static

FROM alpine
WORKDIR /marks
COPY --from=marks-builder /src/marks ./
COPY --from=marks-builder /src/marks-static ./

ENTRYPOINT ["./marks"]
