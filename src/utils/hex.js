export function axialToPixel(col, row, size) {
  const x = size * (Math.sqrt(3) * col + (Math.sqrt(3) / 2) * row);
  const y = size * (3 / 2) * row;
  return { x, y };
}

export function pixelToAxial(px, py, size) {
  const col = ((Math.sqrt(3) / 3) * px - (1 / 3) * py) / size;
  const row = ((2 / 3) * py) / size;
  return axialRound(col, row);
}

export function axialRound(col, row) {
  const s = -col - row;
  let rc = Math.round(col);
  let rr = Math.round(row);
  let rs = Math.round(s);

  const colDiff = Math.abs(rc - col);
  const rowDiff = Math.abs(rr - row);
  const sDiff = Math.abs(rs - s);

  if (colDiff > rowDiff && colDiff > sDiff) {
    rc = -rr - rs;
  } else if (rowDiff > sDiff) {
    rr = -rc - rs;
  }

  return { col: rc || 0, row: rr || 0 };
}

export function axialDistance(a, b) {
  return (Math.abs(a.col - b.col) + Math.abs(a.col + a.row - b.col - b.row) + Math.abs(a.row - b.row)) / 2;
}

export function axialNeighbors(col, row) {
  return [
    { col: col + 1, row: row },
    { col: col - 1, row: row },
    { col: col, row: row + 1 },
    { col: col, row: row - 1 },
    { col: col + 1, row: row - 1 },
    { col: col - 1, row: row + 1 },
  ];
}

export function hexCorners(cx, cy, size) {
  const corners = [];
  for (let i = 0; i < 6; i++) {
    const angle = (Math.PI / 180) * (60 * i - 30);
    corners.push({
      x: cx + size * Math.cos(angle),
      y: cy + size * Math.sin(angle),
    });
  }
  return corners;
}
