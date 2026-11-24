function auditRenderedText(canvas) {
  const commands = JSON.parse(canvas.dataset.textCommandSummary ?? "[]");
  const context = canvas.getContext("2d");
  const logicalWidth = Number.parseFloat(canvas.style.width) || canvas.width;
  const logicalHeight = Number.parseFloat(canvas.style.height) || canvas.height;
  const scaleX = canvas.width / logicalWidth;
  const scaleY = canvas.height / logicalHeight;
  return commands.map((command) => {
    const x = Math.max(0, Math.floor(command.x * scaleX));
    const y = Math.max(0, Math.floor(command.y * scaleY));
    const width = Math.max(1, Math.ceil(command.width * scaleX));
    const height = Math.max(1, Math.ceil(command.height * scaleY));
    const pixels = context.getImageData(x, y, width, height).data;
    const histogram = new Map();
    for (let index = 0; index < pixels.length; index += 4) {
      const rgba = `${pixels[index]},${pixels[index + 1]},${pixels[index + 2]},${pixels[index + 3]}`;
      histogram.set(rgba, (histogram.get(rgba) ?? 0) + 1);
    }
    const pixelCount = pixels.length / 4;
    const modalCount = Math.max(0, ...histogram.values());
    return {
      text: command.text,
      distinctColors: histogram.size,
      nonModalPixels: pixelCount - modalCount,
    };
  });
}

function notifyParent(type, revision, details = {}) {
  if (window.parent === window) {
    return;
  }
  window.parent.postMessage({
    scope: "openswiftui-playground",
    type,
    revision,
    ...details,
  }, window.location.origin);
}

const parameters = new URLSearchParams(window.location.search);
const requestedRevision = parameters.get("revision");
const isStandalone = requestedRevision === null;
const revision = isStandalone ? "standalone" : requestedRevision;

try {
  if (!isStandalone && !/^[1-9]\d*$/.test(requestedRevision)) {
    throw new Error("Invalid preview revision");
  }
  document.documentElement.dataset.previewRevision = revision;
  const moduleURL = isStandalone
    ? new URL("./Bundle/index.js", import.meta.url).href
    : new URL(`/builds/${requestedRevision}/index.js`, window.location.origin).href;
  const { init } = await import(moduleURL);
  await document.fonts.ready;
  await init();
  await new Promise(requestAnimationFrame);

  const canvas = document.querySelector("#canvas");
  if (!canvas?.dataset.displayListVersion) {
    throw new Error("The renderer did not produce a display list frame");
  }
  const pixelAudit = auditRenderedText(canvas);
  canvas.dataset.textPixelAudit = JSON.stringify(pixelAudit);
  canvas.dataset.textPixelPassCount = String(
    pixelAudit.filter((entry) => entry.distinctColors > 1 && entry.nonModalPixels > 10).length
  );
  document.documentElement.dataset.webRendererStatus = "ready";
  notifyParent("preview-ready", revision);
} catch (error) {
  const message = String(error);
  document.documentElement.dataset.webRendererStatus = "failed";
  document.documentElement.dataset.webRendererError = message;
  notifyParent("preview-failed", revision, {
    message,
    stack: error?.stack ?? "",
  });
  console.error(error);
}
