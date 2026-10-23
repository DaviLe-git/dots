import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property string todoPath: Quickshell.env("HOME") + "/todo.txt"

    // { done, prio, created, due, display, raw }
    property var tasks: []
        Component.onCompleted: console.log("[todo] store iniciado. path =", todoPath)
        function tasksForDate(d) {
        const key = Qt.formatDate(d, "yyyy-MM-dd");
        const res = [];
        for (let i = 0; i < tasks.length; i++) {
            const t = tasks[i];
            if (t.due === key || t.created === key
                || (t.created === null && t.due === null))   // ← sem data → todos os dias
                res.push(t);
        }
        return res;
    }

    function toggleDone(task) {
        const lines = fv.text().split("\n");
        const idx = lines.indexOf(task.raw);
        if (idx < 0) return;
        if (lines[idx].startsWith("x ")) {
            let s = lines[idx].slice(2);
            // des-marcar: remove "x " e a data de conclusão, mantendo a de criação
            const m = s.match(/^(\d{4}-\d{2}-\d{2})\s+(?=\d{4}-\d{2}-\d{2}\s)/);
            if (m) s = s.slice(m[0].length);
            lines[idx] = s;
        } else {
            lines[idx] = "x " + Qt.formatDate(new Date(), "yyyy-MM-dd") + " " + lines[idx];
        }
        fv.setTextAndFlush(lines.join("\n"));
    }

    function parseTasks() {
        const txt = fv.text();
        const out = [];
        if (txt && txt.length > 0) {
            const lines = txt.split("\n");
            for (let i = 0; i < lines.length; i++) {
                const raw = lines[i];
                if (raw.trim() === "") continue;

                let body = raw;
                let done = false;
                if (body.startsWith("x ")) { done = true; body = body.slice(2); }

                let prio = "";
                let m = body.match(/^\(([A-Z])\)\s+/);
                if (m) { prio = m[1]; body = body.slice(m[0].length); }

                // tasks done
                let created = null;
                m = body.match(/^(\d{4}-\d{2}-\d{2})\s+(\d{4}-\d{2}-\d{2})\s+/);
                if (m) {
                    created = m[2];
                    body = body.slice(m[0].length);
                } else {
                    m = body.match(/^(\d{4}-\d{2}-\d{2})\s+/);
                    if (m) {
                        if (!done) created = m[1];
                        body = body.slice(m[0].length);
                    }
                }

                let due = null;
                m = body.match(/(^|\s)due:(\d{4}-\d{2}-\d{2})(\s|$)/);
                if (m) due = m[2];

                const display = body.trim().replace(/\s*\bdue:\S+/, "").trim();

                out.push({ done: done, prio: prio, created: created, due: due,
                display: display, raw: raw });
            }
        }
        root.tasks = out;
        console.log("[todo] " + out.length + " tarefas lidas de " + root.todoPath);
    }

    FileView {
        id: fv
        path: root.todoPath
        watchChanges: true
        atomicWrites: true

        onLoaded: root.parseTasks()
        onFileChanged: root.parseTasks()
        onLoadFailed: error => console.log("[todo] ERRO ao abrir:", root.todoPath, error)
    }
}