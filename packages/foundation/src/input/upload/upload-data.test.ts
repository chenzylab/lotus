import { describe, it, expect } from 'vitest';
import { matchAccept, checkFileSize, buildFileItem, applyLimit, isImageFile, type FileItem } from './upload-data.js';

function makeFile(name: string, type: string, size: number): File {
  return new File([new Uint8Array(size)], name, { type });
}

describe('matchAccept', () => {
  it('accept 未设置：全部匹配', () => {
    expect(matchAccept(makeFile('a.png', 'image/png', 10), undefined)).toBe(true);
  });

  it('扩展名匹配', () => {
    expect(matchAccept(makeFile('a.png', 'image/png', 10), '.png,.jpg')).toBe(true);
    expect(matchAccept(makeFile('a.gif', 'image/gif', 10), '.png,.jpg')).toBe(false);
  });

  it('精确 MIME 匹配', () => {
    expect(matchAccept(makeFile('a.png', 'image/png', 10), 'image/png')).toBe(true);
    expect(matchAccept(makeFile('a.png', 'image/png', 10), 'image/jpeg')).toBe(false);
  });

  it('通配 MIME 匹配', () => {
    expect(matchAccept(makeFile('a.png', 'image/png', 10), 'image/*')).toBe(true);
    expect(matchAccept(makeFile('a.pdf', 'application/pdf', 10), 'image/*')).toBe(false);
  });
});

describe('checkFileSize', () => {
  it('maxSize/minSize 均未设置：恒通过', () => {
    expect(checkFileSize(1024 * 1024, undefined, undefined)).toBe(true);
  });

  it('超过 maxSize（KB）：不通过', () => {
    expect(checkFileSize(2000 * 1024, 1000, undefined)).toBe(false);
  });

  it('低于 minSize（KB）：不通过', () => {
    expect(checkFileSize(10 * 1024, undefined, 100)).toBe(false);
  });

  it('在区间内：通过', () => {
    expect(checkFileSize(50 * 1024, 100, 10)).toBe(true);
  });
});

describe('buildFileItem', () => {
  it('uploadTrigger=auto 且校验通过：status=uploading', () => {
    const item = buildFileItem(makeFile('a.png', 'image/png', 10), { uploadTrigger: 'auto' });
    expect(item.status).toBe('uploading');
    expect(item.name).toBe('a.png');
    expect(item.size).toBe(10);
  });

  it('uploadTrigger=custom 且校验通过：status=wait', () => {
    const item = buildFileItem(makeFile('a.png', 'image/png', 10), { uploadTrigger: 'custom' });
    expect(item.status).toBe('wait');
  });

  it('大小越界：status=validateFail，覆盖 uploadTrigger 判断', () => {
    const item = buildFileItem(makeFile('a.png', 'image/png', 2000 * 1024), { uploadTrigger: 'auto', maxSize: 1000 });
    expect(item.status).toBe('validateFail');
    expect(item.validateMessage).toBeTruthy();
  });

  it('每个文件生成唯一 uid', () => {
    const a = buildFileItem(makeFile('a.png', 'image/png', 10), { uploadTrigger: 'auto' });
    const b = buildFileItem(makeFile('b.png', 'image/png', 10), { uploadTrigger: 'auto' });
    expect(a.uid).not.toBe(b.uid);
  });
});

describe('applyLimit', () => {
  const item = (uid: string): FileItem => ({ uid, name: uid, size: 0, status: 'wait', percent: 0 });

  it('limit 未设置：全部追加', () => {
    const result = applyLimit([item('a')], [item('b'), item('c')], undefined);
    expect(result.fileList.map((i) => i.uid)).toEqual(['a', 'b', 'c']);
    expect(result.exceeded).toEqual([]);
  });

  it('limit=1：替换语义，保留新选中的最后一个', () => {
    const result = applyLimit([item('old')], [item('new1'), item('new2')], 1);
    expect(result.fileList.map((i) => i.uid)).toEqual(['new2']);
    expect(result.exceeded.map((i) => i.uid)).toEqual(['old', 'new1']);
  });

  it('limit>1：保留能放下的前 N 个，其余进 exceeded', () => {
    const result = applyLimit([item('a')], [item('b'), item('c'), item('d')], 3);
    expect(result.fileList.map((i) => i.uid)).toEqual(['a', 'b', 'c']);
    expect(result.exceeded.map((i) => i.uid)).toEqual(['d']);
  });

  it('已有文件已达 limit：全部新增进 exceeded', () => {
    const result = applyLimit([item('a'), item('b')], [item('c')], 2);
    expect(result.fileList.map((i) => i.uid)).toEqual(['a', 'b']);
    expect(result.exceeded.map((i) => i.uid)).toEqual(['c']);
  });
});

describe('isImageFile', () => {
  it('MIME 前缀为 image/：判定为图片', () => {
    const item: FileItem = { uid: '1', name: 'a.png', size: 10, status: 'wait', percent: 0, fileInstance: makeFile('a.png', 'image/png', 10) };
    expect(isImageFile(item)).toBe(true);
  });

  it('无 fileInstance 但文件名扩展名是图片：判定为图片', () => {
    const item: FileItem = { uid: '1', name: 'a.jpg', size: 10, status: 'wait', percent: 0 };
    expect(isImageFile(item)).toBe(true);
  });

  it('非图片类型：判定为非图片', () => {
    const item: FileItem = { uid: '1', name: 'a.pdf', size: 10, status: 'wait', percent: 0, fileInstance: makeFile('a.pdf', 'application/pdf', 10) };
    expect(isImageFile(item)).toBe(false);
  });
});
