const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');
const ctx = vm.createContext({});
vm.runInContext(fs.readFileSync('ColorUtils.js', 'utf8').replace(/^\.pragma library/, ''), ctx);
const plain = v => JSON.parse(JSON.stringify(v));
assert.deepEqual(plain(ctx.parseAny('#abc')), {r:170,g:187,b:204});
assert.deepEqual(plain(ctx.parseAny('rgb(30, 144, 255)')), {r:30,g:144,b:255});
assert.deepEqual(plain(ctx.parseAny('rgb(30 144 255)')), {r:30,g:144,b:255});
assert.deepEqual(plain(ctx.parseAny('hsl(120, 100%, 50%)')), {r:0,g:255,b:0});
for (const invalid of ['rgb(1, 2, 3', 'prefix rgb(1, 2, 3)', 'hsl(120, 100%, 50%)junk', '', '#ggg'])
  assert.equal(ctx.parseAny(invalid), null, invalid);
assert.equal(ctx.format({r:30,g:144,b:255}, 'HEX', true), '#1e90ff');
assert.equal(ctx.contrastRatio({r:0,g:0,b:0}, {r:255,g:255,b:255}), 21);
assert.equal(ctx.wcagLevels(4.49).aaNormal, false);
assert.equal(ctx.wcagLevels(4.5).aaNormal, true);
console.log('Color conversion and contrast tests passed');
