var MiscUtils;
(function (MiscUtils) {
    function toArray(nodeList) {
        return Array.prototype.slice.call(nodeList);
    }
    MiscUtils.toArray = toArray;
    function getCenter(rectangle) {
        return {
            x: getMedian(rectangle.left, rectangle.right),
            y: getMedian(rectangle.top, rectangle.bottom)
        };
    }
    MiscUtils.getCenter = getCenter;
    function getTop(rectangle) {
        return {
            x: getMedian(rectangle.left, rectangle.right),
            y: rectangle.top
        };
    }
    MiscUtils.getTop = getTop;
    function getBottom(rectangle) {
        return {
            x: getMedian(rectangle.left, rectangle.right),
            y: rectangle.bottom
        };
    }
    MiscUtils.getBottom = getBottom;
    function getMedian(a, b) {
        return Math.min(a, b) + Math.abs(a - b) / 2;
    }
    MiscUtils.getMedian = getMedian;
    function getIntersection(inner, outer, rectangle) {
        var height = outer.y - inner.y;
        var width = outer.x - inner.x;
        if (inner.x < outer.x) {
            var distanceFromRight = rectangle.right - inner.x;
            var rightY = inner.y + height * distanceFromRight / width;
            if ((rectangle.top <= rightY) && (rightY <= rectangle.bottom)) {
                return {
                    x: rectangle.right,
                    y: rightY
                };
            }
        }
        if (outer.x < inner.x) {
            var distanceFromLeft = inner.x - rectangle.left;
            var leftY = inner.y - height * distanceFromLeft / width;
            if ((rectangle.top <= leftY) && (leftY <= rectangle.bottom)) {
                return {
                    x: rectangle.left,
                    y: leftY
                };
            }
        }
        if (inner.y < outer.y) {
            var distanceFromBottom = rectangle.bottom - inner.y;
            var bottomX = inner.x + width * distanceFromBottom / height;
            if ((rectangle.left <= bottomX) && (bottomX <= rectangle.right)) {
                return {
                    x: bottomX,
                    y: rectangle.bottom
                };
            }
        }
        if (outer.y < inner.y) {
            var distanceFromTop = inner.y - rectangle.top;
            var topX = inner.x - width * distanceFromTop / height;
            if ((rectangle.left <= topX) && (topX <= rectangle.right)) {
                return {
                    x: topX,
                    y: rectangle.top
                };
            }
        }
        return null;
    }
    MiscUtils.getIntersection = getIntersection;
})(MiscUtils || (MiscUtils = {}));
///<reference path="MiscUtils.ts"/>
var SvgConnectors;
(function (SvgConnectors) {
    function manage() {
        refreshAll();
        document.addEventListener("DOMSubtreeModified", refreshAll);
        window.addEventListener("resize", refreshAll);
        document.addEventListener("scroll", refreshAll);
    }
    SvgConnectors.manage = manage;
    function refreshAll() {
        var sourceAttribute = "data-s";
        var targetAttribute = "data-t";
        var connectors = MiscUtils.toArray(document.querySelectorAll("[" + sourceAttribute + "][" + targetAttribute + "]"));
        connectors.forEach(function (node) {
            var connector = node;
            var source = document.getElementById(connector.getAttribute(sourceAttribute));
            var target = document.getElementById(connector.getAttribute(targetAttribute));
            connect(connector, source, target);
        });
    }
    window.rA = refreshAll;
    function connect(connectorNode, source, target) {
        refresh(connectorNode, source, target);
        observe(source, connectorNode, source, target);
        observe(target, connectorNode, source, target);
    }
    function refresh(connectorNode, source, target) {
        if (connectorNode instanceof SVGElement) {
            var connector = connectorNode;
            var sourceRect = toPage(source.getBoundingClientRect());
            var targetRect = toPage(target.getBoundingClientRect());
            var sourceCenter = MiscUtils.getCenter(sourceRect);
            var targetCenter = MiscUtils.getCenter(targetRect);
            // var startPoint = MiscUtils.getIntersection(sourceCenter, targetCenter, sourceRect);
            // var endPoint = MiscUtils.getIntersection(targetCenter, sourceCenter, targetRect);
            var startPoint = MiscUtils.getBottom(sourceRect);
            var endPoint = MiscUtils.getTop(targetRect);
            switch (connector.tagName.toLowerCase()) {
                case "line":
                    connector.setAttribute("x1", startPoint.x.toString());
                    connector.setAttribute("y1", startPoint.y.toString());
                    connector.setAttribute("x2", endPoint.x.toString());
                    connector.setAttribute("y2", endPoint.y.toString());
                    break;
                case "text":
                    connector.setAttribute("text-anchor", "middle");
                    var x = MiscUtils.getMedian(startPoint.x, endPoint.x);
                    connector.setAttribute("x", x.toString());
                    var y = MiscUtils.getMedian(startPoint.y, endPoint.y);
                    connector.setAttribute("y", y.toString());
                    break;
                case "g":
                    var children = MiscUtils.toArray(connector.childNodes);
                    children.forEach(function (child) { return refresh(child, source, target); });
                    break;
            }
            var containerSvg = connector.ownerSVGElement;
            if (containerSvg != null) {
                var scrollWidth = Math.max(document.documentElement.scrollWidth, document.body.scrollWidth); // XXX cross-browser behavior
                containerSvg.setAttribute("width", scrollWidth.toString());
                var scrollHeight = Math.max(document.documentElement.scrollHeight, document.body.scrollHeight); // XXX cross-browser behavior
                containerSvg.setAttribute("height", scrollHeight.toString());
            }
        }
    }
    function toPage(rectangle) {
        return {
            left: rectangle.left + window.pageXOffset,
            top: rectangle.top + window.pageYOffset,
            right: rectangle.right + window.pageXOffset,
            bottom: rectangle.bottom + window.pageYOffset,
            width: rectangle.width,
            height: rectangle.height
        };
    }
    function observe(observed, connectorNode, source, target) {
        var observer = new MutationObserver(function (_, __) {
            refresh(connectorNode, source, target);
        });
        observer.observe(observed, {
            attributes: true
        });
    }
})(SvgConnectors || (SvgConnectors = {}));
///<reference path="MiscUtils.ts"/>
var DraggableElements;
(function (DraggableElements) {
    function manage() {
        var format = "text/plain";
        MiscUtils.toArray(document.querySelectorAll("[draggable=true]")).forEach(function (node) {
            var element = node;
            element.ondragstart = function (event) {
                event.dataTransfer.setData(format, element.id);
            };
        });
        document.ondragover = function (event) {
            var draggedElement = document.getElementById(event.dataTransfer.getData(format));
            draggedElement.style.left = event.pageX.toString() + "px";
            draggedElement.style.top = event.pageY.toString() + "px";
        };
    }
    DraggableElements.manage = manage;
})(DraggableElements || (DraggableElements = {}));
///<reference path="../main/SvgConnectors.ts"/>
///<reference path="../main/DraggableElements.ts"/>
window.onload = function () {
    SvgConnectors.manage();
    DraggableElements.manage();
};