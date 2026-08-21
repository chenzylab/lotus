import { describe, it, expect } from 'vitest';
import { TagInputFoundation, type TagInputState, type TagInputFoundationOptions } from './foundation.js';
import type { Adapter } from '../../base/adapter.js';

function createFoundation(opts: Partial<TagInputFoundationOptions> = {}, initial: Partial<TagInputState> = {}) {
  let state: TagInputState = { tagsArray: [], inputValue: '', ...initial };
  const adapter: Adapter<TagInputState> = {
    getState: () => state,
    setState: (patch) => { state = { ...state, ...patch }; },
  };
  const foundation = new TagInputFoundation(adapter, { separator: ',', allowDuplicates: true, ...opts });
  return { foundation, getState: () => state };
}

describe('TagInputFoundation', () => {
  describe('setInputValue', () => {
    it('更新 inputValue', () => {
      const { foundation, getState } = createFoundation();
      foundation.setInputValue('hello');
      expect(getState().inputValue).toBe('hello');
    });
  });

  describe('addTagsFromInput', () => {
    it('inputValue 为空：返回 null，不做任何变更', () => {
      const { foundation, getState } = createFoundation();
      const before = getState();
      expect(foundation.addTagsFromInput(false)).toBeNull();
      expect(getState()).toEqual(before);
    });

    it('单个标签：追加到 tagsArray，inputValue 清空', () => {
      const { foundation, getState } = createFoundation({}, { inputValue: 'tag1' });
      const result = foundation.addTagsFromInput(false);
      expect(result?.tagsArray).toEqual(['tag1']);
      expect(result?.added).toEqual(['tag1']);
      expect(getState().tagsArray).toEqual(['tag1']);
      expect(getState().inputValue).toBe('');
    });

    it('按分隔符拆分成多个标签', () => {
      const { foundation, getState } = createFoundation({}, { inputValue: 'a,b,c' });
      const result = foundation.addTagsFromInput(false);
      expect(result?.tagsArray).toEqual(['a', 'b', 'c']);
      expect(getState().tagsArray).toEqual(['a', 'b', 'c']);
    });

    it('allowDuplicates=false：重复项被过滤', () => {
      const { foundation, getState } = createFoundation(
        { allowDuplicates: false },
        { inputValue: 'a,b', tagsArray: ['a'] },
      );
      const result = foundation.addTagsFromInput(false);
      expect(result?.added).toEqual(['b']);
      expect(getState().tagsArray).toEqual(['a', 'b']);
    });

    it('max 限制：超出部分不添加，inputValue 仍清空', () => {
      const { foundation, getState } = createFoundation(
        { max: 2 },
        { inputValue: 'a,b,c', tagsArray: [] },
      );
      const result = foundation.addTagsFromInput(false);
      expect(result?.tagsArray).toEqual(['a', 'b']);
      expect(result?.exceeded).toEqual(['a', 'b', 'c']);
      expect(getState().inputValue).toBe('');
    });

    it('受控模式：不更新 tagsArray，但仍清空 inputValue', () => {
      const { foundation, getState } = createFoundation({}, { inputValue: 'tag1' });
      foundation.addTagsFromInput(true);
      expect(getState().tagsArray).toEqual([]);
      expect(getState().inputValue).toBe('');
    });

    it('全部被过滤为空：仍清空输入框，added 为空', () => {
      const { foundation, getState } = createFoundation({}, { inputValue: '  ' });
      const result = foundation.addTagsFromInput(false);
      expect(result?.added).toEqual([]);
      expect(getState().inputValue).toBe('');
    });
  });

  describe('removeLastTag', () => {
    it('inputValue 非空：不触发', () => {
      const { foundation } = createFoundation({}, { inputValue: 'x', tagsArray: ['a'] });
      expect(foundation.removeLastTag(false)).toBeNull();
    });

    it('tagsArray 为空：不触发', () => {
      const { foundation } = createFoundation({}, { inputValue: '', tagsArray: [] });
      expect(foundation.removeLastTag(false)).toBeNull();
    });

    it('删除最后一个标签', () => {
      const { foundation, getState } = createFoundation({}, { tagsArray: ['a', 'b', 'c'] });
      const result = foundation.removeLastTag(false);
      expect(result?.removed).toBe('c');
      expect(result?.index).toBe(2);
      expect(getState().tagsArray).toEqual(['a', 'b']);
    });

    it('受控模式：不更新内部 state', () => {
      const { foundation, getState } = createFoundation({}, { tagsArray: ['a', 'b'] });
      foundation.removeLastTag(true);
      expect(getState().tagsArray).toEqual(['a', 'b']);
    });
  });

  describe('removeTagAt', () => {
    it('按索引移除', () => {
      const { foundation, getState } = createFoundation({}, { tagsArray: ['a', 'b', 'c'] });
      const result = foundation.removeTagAt(1, false);
      expect(result?.removed).toBe('b');
      expect(getState().tagsArray).toEqual(['a', 'c']);
    });

    it('索引越界：返回 null', () => {
      const { foundation } = createFoundation({}, { tagsArray: ['a'] });
      expect(foundation.removeTagAt(5, false)).toBeNull();
    });
  });

  describe('clearAll', () => {
    it('非受控：清空 tagsArray 和 inputValue', () => {
      const { foundation, getState } = createFoundation({}, { tagsArray: ['a', 'b'], inputValue: 'x' });
      foundation.clearAll(false);
      expect(getState().tagsArray).toEqual([]);
      expect(getState().inputValue).toBe('');
    });

    it('受控：只清空 inputValue', () => {
      const { foundation, getState } = createFoundation({}, { tagsArray: ['a', 'b'], inputValue: 'x' });
      foundation.clearAll(true);
      expect(getState().tagsArray).toEqual(['a', 'b']);
      expect(getState().inputValue).toBe('');
    });
  });

  describe('moveTag', () => {
    it('非受控：重排 tagsArray', () => {
      const { foundation, getState } = createFoundation({}, { tagsArray: ['a', 'b', 'c'] });
      const result = foundation.moveTag(0, 2, false);
      expect(result).toEqual(['b', 'c', 'a']);
      expect(getState().tagsArray).toEqual(['b', 'c', 'a']);
    });

    it('受控：不更新内部 state', () => {
      const { foundation, getState } = createFoundation({}, { tagsArray: ['a', 'b'] });
      foundation.moveTag(0, 1, true);
      expect(getState().tagsArray).toEqual(['a', 'b']);
    });
  });

  describe('syncTagsArray', () => {
    it('受控回灌', () => {
      const { foundation, getState } = createFoundation();
      foundation.syncTagsArray(['x', 'y']);
      expect(getState().tagsArray).toEqual(['x', 'y']);
    });
  });
});
