pragma Singleton
pragma ComponentBehavior: Bound

import qs.modules.common
import Quickshell;
import Quickshell.Io;
import QtQuick;

/**
 * Simple to-do list manager.
 * Each item is an object with "content" and "done" properties.
 */
Singleton {
    id: root
    property var filePath: Directories.todoPath
    property var list: []
    
    function addItem(item) {
        list.push(item)
        root.list = list.slice(0)
        todoFileView.setText(JSON.stringify(root.list))
    }

    function addTask(desc) {
        if (!desc || desc.trim().length === 0) return
        const item = {
            "content": desc.trim(),
            "done": false,
        }
        addItem(item)
    }

    function toggleTask(index) {
        if (index >= 0 && index < list.length) {
            list[index].done = !list[index].done
            root.list = list.slice(0)
            todoFileView.setText(JSON.stringify(root.list))
        }
    }

    function editTask(index, newContent) {
        if (index >= 0 && index < list.length && newContent && newContent.trim().length > 0) {
            list[index].content = newContent.trim()
            root.list = list.slice(0)
            todoFileView.setText(JSON.stringify(root.list))
        }
    }

    function markDone(index) {
        if (index >= 0 && index < list.length) {
            list[index].done = true
            root.list = list.slice(0)
            todoFileView.setText(JSON.stringify(root.list))
        }
    }

    function markUnfinished(index) {
        if (index >= 0 && index < list.length) {
            list[index].done = false
            root.list = list.slice(0)
            todoFileView.setText(JSON.stringify(root.list))
        }
    }

    function deleteItem(index) {
        if (index >= 0 && index < list.length) {
            list.splice(index, 1)
            root.list = list.slice(0)
            todoFileView.setText(JSON.stringify(root.list))
        }
    }

    function refresh() {
        todoFileView.reload()
    }

    Component.onCompleted: {
        refresh()
    }

    FileView {
        id: todoFileView
        path: root.filePath
        onLoaded: {
            const fileContents = todoFileView.text()
            try {
                root.list = JSON.parse(fileContents)
            } catch (e) {
                root.list = []
            }
            if (!root.list || root.list.length === 0) {
                root.list = [
                    { "content": "Study / Deep Focus", "done": true },
                    { "content": "Build / Code Hyprland", "done": true },
                    { "content": "Improve / Refactor UI", "done": false },
                    { "content": "Be better / Repeat ♡", "done": false }
                ]
                todoFileView.setText(JSON.stringify(root.list))
            }
        }
        onLoadFailed: (error) => {
            root.list = [
                { "content": "Study / Deep Focus", "done": true },
                { "content": "Build / Code Hyprland", "done": true },
                { "content": "Improve / Refactor UI", "done": false },
                { "content": "Be better / Repeat ♡", "done": false }
            ]
            todoFileView.setText(JSON.stringify(root.list))
        }
    }

    IpcHandler {
        target: "todo"
        function add(content: string): void { root.addTask(content); }
        function remove(index: int): void { root.deleteItem(index); }
        function toggle(index: int): void { root.toggleTask(index); }
        function edit(index: int, content: string): void { root.editTask(index, content); }
        function clear(): void { root.list = []; todoFileView.setText(JSON.stringify([])); }
    }
}
