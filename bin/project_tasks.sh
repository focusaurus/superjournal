setup() {
    cd "${TASK_DIR}/.."
    PROJECT_DIR=$(pwd)
    cd -
}

app:test() {
    app:dev_start
    set -e
    cdpd
    #Due to a zombie issue, we can't run all the tests at once
    for DIR in unit application
    do
        jasbin "spec/js/${DIR}"/*Spec.coffee
    done
}
