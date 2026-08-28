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
      const result = foundation.addFiles([file], false);
      expect(result.added).toHaveLength(1);
      expect(result.added[0]!.status).toBe('uploading');
      expect(getState().fileList).toHaveLength(1);
    });

    it('limit 裁剪：超出部分进 exceeded', () => {
      const { foundation } = createFoundation({ limit: 1 });
      const file1 = makeFile('a.png', 'image/png', 10);
      foundation.addFiles([file1], false);
      const file2 = makeFile('b.png', 'image/png', 10);
      const result = foundation.addFiles([file2], false);
      expect(result.fileList).toHaveLength(1);
      expect(result.fileList[0]!.name).toBe('b.png');
      expect(result.exceeded).toHaveLength(1);
    });

    it('回归防护：isControlled=true 时不写 state.fileList，但返回值仍带完整新列表供 onChange 使用', () => {
      const { foundation, getState } = createFoundation();
      const file = makeFile('a.png', 'image/png', 10);
      const result = foundation.addFiles([file], true);
      expect(result.added).toHaveLength(1);
      expect(result.fileList).toHaveLength(1);
      expect(getState().fileList).toHaveLength(0);
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
      const next = foundation.applyBeforeUploadResult('u1', { shouldUpload: true }, false);
      expect(next?.item.status).toBe('uploading');
      expect(getState().fileList[0]!.status).toBe('uploading');
    });

    it('shouldUpload=false：状态置为指定 status（默认 validateFail）', () => {
      const item: FileItem = { uid: 'u1', name: 'a.png', size: 10, status: 'wait', percent: 0 };
      const { foundation } = createFoundation({}, [item]);
      const next = foundation.applyBeforeUploadResult('u1', { shouldUpload: false }, false);
      expect(next?.item.status).toBe('validateFail');
    });

    it('fileInstance 替换：同步 name/size', () => {
      const item: FileItem = { uid: 'u1', name: 'old.png', size: 10, status: 'wait', percent: 0 };
      const { foundation } = createFoundation({}, [item]);
      const newFile = makeFile('new.png', 'image/png', 999);
      const next = foundation.applyBeforeUploadResult('u1', { shouldUpload: true, fileInstance: newFile }, false);
      expect(next?.item.name).toBe('new.png');
      expect(next?.item.size).toBe(999);
    });

    it('uid 不存在：返回 null', () => {
      const { foundation } = createFoundation();
      expect(foundation.applyBeforeUploadResult('nonexistent', { shouldUpload: true }, false)).toBeNull();
    });

    it('回归防护：isControlled=true 时不写 state，返回值仍带完整新列表', () => {
      const item: FileItem = { uid: 'u1', name: 'a.png', size: 10, status: 'wait', percent: 0 };
      const { foundation, getState } = createFoundation({}, [item]);
      const next = foundation.applyBeforeUploadResult('u1', { shouldUpload: true }, true);
      expect(next?.item.status).toBe('uploading');
      expect(next?.fileList[0]!.status).toBe('uploading');
      expect(getState().fileList[0]!.status).toBe('wait');
    });
  });

  describe('上传生命周期状态迁移', () => {
    const item: FileItem = { uid: 'u1', name: 'a.png', size: 10, status: 'wait', percent: 0 };

    it('markUploading', () => {
      const { foundation } = createFoundation({}, [item]);
      const next = foundation.markUploading('u1', false);
      expect(next?.item.status).toBe('uploading');
      expect(next?.item.percent).toBe(0);
    });

    it('handleProgress：clamp 到 0-100', () => {
      const { foundation } = createFoundation({}, [item]);
      expect(foundation.handleProgress('u1', 50, false)?.item.percent).toBe(50);
      expect(foundation.handleProgress('u1', 150, false)?.item.percent).toBe(100);
      expect(foundation.handleProgress('u1', -10, false)?.item.percent).toBe(0);
    });

    it('handleSuccess：status=success, percent=100', () => {
      const { foundation } = createFoundation({}, [item]);
      const next = foundation.handleSuccess('u1', { url: 'https://example.com/a.png' }, false);
      expect(next?.item.status).toBe('success');
      expect(next?.item.percent).toBe(100);
      expect(next?.item.response).toEqual({ url: 'https://example.com/a.png' });
    });

    it('handleError：status=uploadFail', () => {
      const { foundation } = createFoundation({}, [item]);
      const next = foundation.handleError('u1', '网络错误', false);
      expect(next?.item.status).toBe('uploadFail');
      expect(next?.item.validateMessage).toBe('网络错误');
    });

    it('retry：不检查当前状态，直接重置为 uploading', () => {
      const failedItem: FileItem = { uid: 'u1', name: 'a.png', size: 10, status: 'success', percent: 100 };
      const { foundation } = createFoundation({}, [failedItem]);
      const next = foundation.retry('u1', false);
      expect(next?.item.status).toBe('uploading');
      expect(next?.item.percent).toBe(0);
    });

    it('回归防护：受控模式下 handleProgress/handleSuccess/handleError 都不写 state，只返回结果', () => {
      const { foundation, getState } = createFoundation({}, [item]);
      const progressResult = foundation.handleProgress('u1', 50, true);
      expect(progressResult?.item.percent).toBe(50);
      expect(getState().fileList[0]!.percent).toBe(0);

      const successResult = foundation.handleSuccess('u1', { ok: true }, true);
      expect(successResult?.item.status).toBe('success');
      expect(getState().fileList[0]!.status).toBe('wait');
    });

    it('并发多文件上传：其中一个文件失败不影响其他文件各自的进度/状态（按 uid 定位单项，不做整体重置）', () => {
      const items: FileItem[] = [
        { uid: 'u1', name: 'a.png', size: 10, status: 'uploading', percent: 30 },
        { uid: 'u2', name: 'b.png', size: 10, status: 'uploading', percent: 60 },
        { uid: 'u3', name: 'c.png', size: 10, status: 'uploading', percent: 90 },
      ];
      const { foundation, getState } = createFoundation({}, items);

      foundation.handleError('u2', '网络错误', false);
      const list = getState().fileList;
      expect(list.find((f) => f.uid === 'u2')?.status).toBe('uploadFail');
      expect(list.find((f) => f.uid === 'u1')).toEqual(items[0]);
      expect(list.find((f) => f.uid === 'u3')).toEqual(items[2]);

      foundation.handleProgress('u1', 50, false);
      foundation.handleSuccess('u3', { url: 'https://example.com/c.png' }, false);
      const finalList = getState().fileList;
      expect(finalList.find((f) => f.uid === 'u1')?.percent).toBe(50);
      expect(finalList.find((f) => f.uid === 'u2')?.status).toBe('uploadFail');
      expect(finalList.find((f) => f.uid === 'u3')?.status).toBe('success');
    });
  });

  describe('remove / replace / clear', () => {
    it('remove：按 uid 移除', () => {
      const items: FileItem[] = [
        { uid: 'u1', name: 'a.png', size: 10, status: 'success', percent: 100 },
        { uid: 'u2', name: 'b.png', size: 10, status: 'success', percent: 100 },
      ];
      const { foundation, getState } = createFoundation({}, items);
      foundation.remove('u1', false);
      expect(getState().fileList.map((i) => i.uid)).toEqual(['u2']);
    });

    it('replace：位置不变，内容替换为新文件', () => {
      const items: FileItem[] = [
        { uid: 'u1', name: 'a.png', size: 10, status: 'success', percent: 100 },
        { uid: 'u2', name: 'b.png', size: 10, status: 'success', percent: 100 },
      ];
      const { foundation, getState } = createFoundation({}, items);
      const newFile = makeFile('c.png', 'image/png', 20);
      const result = foundation.replace('u1', newFile, false);
      expect(result?.fileList[0]!.name).toBe('c.png');
      expect(result?.fileList[1]!.uid).toBe('u2');
      expect(getState().fileList).toHaveLength(2);
    });

    it('clear：清空全部', () => {
      const items: FileItem[] = [{ uid: 'u1', name: 'a.png', size: 10, status: 'success', percent: 100 }];
      const { foundation, getState } = createFoundation({}, items);
      foundation.clear(false);
      expect(getState().fileList).toEqual([]);
    });

    it('回归防护：isControlled=true 时 remove/replace/clear 都不写 state', () => {
      const items: FileItem[] = [{ uid: 'u1', name: 'a.png', size: 10, status: 'success', percent: 100 }];
      const { foundation, getState } = createFoundation({}, items);

      const removed = foundation.remove('u1', true);
      expect(removed).toEqual([]);
      expect(getState().fileList).toHaveLength(1);

      const newFile = makeFile('c.png', 'image/png', 20);
      const replaced = foundation.replace('u1', newFile, true);
      expect(replaced?.fileList[0]!.name).toBe('c.png');
      expect(getState().fileList[0]!.name).toBe('a.png');

      foundation.clear(true);
      expect(getState().fileList).toHaveLength(1);
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
