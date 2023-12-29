# Build container
FROM golang:latest AS builder

# Set the working directory inside the container
WORKDIR /build

# Copy the go module files to the workspace root
COPY go.mod .
COPY go.sum .

# Download dependencies
RUN go mod download

# Copy the source code to the workspace root
COPY . .

# Build the Go application
RUN CGO_ENABLED=0 GOOS=linux go build -o spap .

# Actual container
FROM alpine:latest

# Set the working directory inside the container
WORKDIR /spap
RUN addgroup --system application && adduser --system spap --ingroup application

# Copy the binary from the build container
COPY --from=builder /build/spap .

# Make the binary executable
RUN chown spap:application spap && \
    chmod +x spap

USER spap

# Command to run the application
CMD ["./spap"]
