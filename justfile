build-all:
    cd hugo && just build
    cd saga-ssg && just build
    cd publish-ssg && just build

clean-all:
    cd hugo && just clean
    cd saga-ssg && just clean
    cd publish-ssg && just clean

serve-all: build-all
    #!/usr/bin/env bash
    python3 -m http.server 8001 --directory hugo/public &
    python3 -m http.server 8002 --directory saga-ssg/deploy &
    python3 -m http.server 8003 --directory publish-ssg/Output &
    echo "Hugo:    http://localhost:8001"
    echo "Saga:    http://localhost:8002"
    echo "Publish: http://localhost:8003"
    echo "Press Ctrl+C to stop all servers"
    wait
