import { describe, it, expect } from 'vitest';
import { UploadFoundation, type UploadState, type UploadFoundationOptions } from './foundation.js';
import type { Adapter } from '../../base/adapter.js';
import type { FileItem } from './upload-data.js';

function makeFile(name: string, type: string, size: number): File {
  return new File([new Uint8Array(size)], name, { type });
}

function createFoundation(opts: Partial<UploadFoundationOptions> = {}, initialFileList: FileItem[] = []) {
  let state: UploadState = { fileList: initialFileList, dragAreaStatus: 'default' };
  const adapter: Adapter<UploadState> = {
    getState: () => state,
    setState: (patch) => { state = { ...state, ...patch }; },
  };
  const foundation = new UploadFoundation(adapter, { uploadTrigger: 'auto', ...opts });
  return { foundation, getState: () => state };
}

describe('UploadFoundation', () => {
  describe('filterByAccept', () => {
    it('按 accept 过滤，返回匹配/不匹配两组', () => {
      const { foundation } = createFoundation({ accept: '.png' });
      const png = makeFile('a.png', 'image/png', 10);
      const pdf = makeFile('a.pdf', 'application/pdf', 10);
      const result = foundation.filterByAccept([png, pdf]);
      expect(result.matched).toEqual([png]);
      expect(result.rejected).toEqual([pdf]);
    });
  });

  describe('addFiles', () => {
    it('新增文件进入 fileList，auto 触发时状态为 uploading', () => {
      const { foundation, getState } = createFoundation();
      const file = makeFile('a.png', 'image/png', 10);
      const result = foundation.addFiles([file]);
      expect(result.added).toHaveLength(1);
      expect(result.added[0]!.status).toBe('uploading');
      expect(getState().fileList).toHaveLength(1);
    });

    it('limit 裁剪：超出部分进 exceeded', () => {
      const { foundation } = createFoundation({ limit: 1 });
      const file1 = makeFile('a.png', 'image/png', 10);
      foundation.addFiles([file1]);
      const file2 = makeFile('b.png', 'image/png', 10);
      const result = foundation.addFiles([file2]);
      expect(result.fileList).toHaveLength(1);
      expect(result.fileList[0]!.name).toBe('b.png');
      expect(result.exceeded).toHaveLength(1);
    });
  });

  describe('resolveBeforeUploadResult', () => {
    const { foundation } = createFoundation();

    it('undefined/true：shouldUpload=true', () => {
      expect(foundation.resolveBeforeUploadResult(undefined)).toEqual({ shouldUpload: true });
      expect(foundation.resolveBeforeUploadResult(true)).toEqual({ shouldUpload: true });
    });

    it('false：shouldUpload=false, status=validateFail', () => {
      expect(foundation.resolveBeforeUploadResult(false)).toEqual({ shouldUpload: false, status: 'validateFail' });
    });

    it('object 返回值：透传字段，shouldUpload 默认为 true 除非显式 false', () => {
      const result = foundation.resolveBeforeUploadResult({ validateMessage: 'custom msg' });
      expect(result.shouldUpload).toBe(true);
      expect(result.validateMessage).toBe('custom msg');
    });

    it('object 返回值显式 shouldUpload=false：保留', () => {
      const result = foundation.resolveBeforeUploadResult({ shouldUpload: false, status: 'validateFail' });
      expect(result.shouldUpload).toBe(false);
    });
  });

  describe('applyBeforeUploadResult', () => {
    it('shouldUpload=true：状态置为 uploading', () => {
      const item: FileItem = { uid: 'u1', name: 'a.png', size: 10, status: 'wait', percent: 0 };
      const { foundation, getState } = createFoundation({}, [item]);
      const next = foundation.applyBeforeUploadResult('u1', { shouldUpload: true });
      expect(next?.status).toBe('uploading');
      expect(getState().fileList[0]!.status).toBe('uploading');
    });

    it('shouldUpload=false：状态置为指定 status（默认 validateFail）', () => {
      const item: FileItem = { uid: 'u1', name: 'a.png', size: 10, status: 'wait', percent: 0 };
      const { foundation } = createFoundation({}, [item]);
      const next = foundation.applyBeforeUploadResult('u1', { shouldUpload: false });
      expect(next?.status).toBe('validateFail');
    });

    it('fileInstance 替换：同步 name/size', () => {
      const item: FileItem = { uid: 'u1', name: 'old.png', size: 10, status: 'wait', percent: 0 };
      const { foundation } = createFoundation({}, [item]);
      const newFile = makeFile('new.png', 'image/png', 999);
      const next = foundation.applyBeforeUploadResult('u1', { shouldUpload: true, fileInstance: newFile });
      expect(next?.name).toBe('new.png');
      expect(next?.size).toBe(999);
    });

    it('uid 不存在：返回 null', () => {
      const { foundation } = createFoundation();
      expect(foundation.applyBeforeUploadResult('nonexistent', { shouldUpload: true })).toBeNull();
    });
  });

  describe('上传生命周期状态迁移', () => {
    const item: FileItem = { uid: 'u1', name: 'a.png', size: 10, status: 'wait', percent: 0 };

    it('markUploading', () => {
      const { foundation } = createFoundation({}, [item]);
      const next = foundation.markUploading('u1');
      expect(next?.status).toBe('uploading');
      expect(next?.percent).toBe(0);
    });

    it('handleProgress：clamp 到 0-100', () => {
      const { foundation } = createFoundation({}, [item]);
      expect(foundation.handleProgress('u1', 50)?.percent).toBe(50);
      expect(foundation.handleProgress('u1', 150)?.percent).toBe(100);
      expect(foundation.handleProgress('u1', -10)?.percent).toBe(0);
    });

    it('handleSuccess：status=success, percent=100', () => {
      const { foundation } = createFoundation({}, [item]);
      const next = foundation.handleSuccess('u1', { url: 'https://example.com/a.png' });
      expect(next?.status).toBe('success');
      expect(next?.percent).toBe(100);
      expect(next?.response).toEqual({ url: 'https://example.com/a.png' });
    });

    it('handleError：status=uploadFail', () => {
      const { foundation } = createFoundation({}, [item]);
      const next = foundation.handleError('u1', '网络错误');
      expect(next?.status).toBe('uploadFail');
      expect(next?.validateMessage).toBe('网络错误');
    });

    it('retry：不检查当前状态，直接重置为 uploading', () => {
      const failedItem: FileItem = { uid: 'u1', name: 'a.png', size: 10, status: 'success', percent: 100 };
      const { foundation } = createFoundation({}, [failedItem]);
      const next = foundation.retry('u1');
      expect(next?.status).toBe('uploading');
      expect(next?.percent).toBe(0);
    });
  });

  describe('remove / replace / clear', () => {
    it('remove：按 uid 移除', () => {
      const items: FileItem[] = [
        { uid: 'u1', name: 'a.png', size: 10, status: 'success', percent: 100 },
        { uid: 'u2', name: 'b.png', size: 10, status: 'success', percent: 100 },
      ];
      const { foundation, getState } = createFoundation({}, items);
      foundation.remove('u1');
      expect(getState().fileList.map((i) => i.uid)).toEqual(['u2']);
    });

    it('replace：位置不变，内容替换为新文件', () => {
      const items: FileItem[] = [
        { uid: 'u1', name: 'a.png', size: 10, status: 'success', percent: 100 },
        { uid: 'u2', name: 'b.png', size: 10, status: 'success', percent: 100 },
      ];
      const { foundation, getState } = createFoundation({}, items);
      const newFile = makeFile('c.png', 'image/png', 20);
      const result = foundation.replace('u1', newFile);
      expect(result?.fileList[0]!.name).toBe('c.png');
      expect(result?.fileList[1]!.uid).toBe('u2');
      expect(getState().fileList).toHaveLength(2);
    });

    it('clear：清空全部', () => {
      const items: FileItem[] = [{ uid: 'u1', name: 'a.png', size: 10, status: 'success', percent: 100 }];
      const { foundation, getState } = createFoundation({}, items);
      foundation.clear();
      expect(getState().fileList).toEqual([]);
    });
  });

  describe('拖拽悬停态', () => {
    it('setDragAreaStatus', () => {
      const { foundation, getState } = createFoundation();
      foundation.setDragAreaStatus('legal');
      expect(getState().dragAreaStatus).toBe('legal');
    });
  });

  describe('syncFileList', () => {
    it('受控同步：整体替换 fileList', () => {
      const { foundation, getState } = createFoundation();
      const items: FileItem[] = [{ uid: 'u1', name: 'a.png', size: 10, status: 'success', percent: 100 }];
      foundation.syncFileList(items);
      expect(getState().fileList).toEqual(items);
    });
  });
});
