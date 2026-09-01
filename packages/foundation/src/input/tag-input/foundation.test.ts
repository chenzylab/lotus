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

    it('传入自定义 splitFn（对齐 Semi split）：覆盖默认按 separator 拆分的逻辑（回归防护：此前只有 checkInputMaxLength 接收自定义拆分函数，addTagsFromInput 硬编码用默认 splitBySeparator，导致 split 配置了却对提交结果不生效——按空格输入的内容 Enter 后被当成默认逗号分隔的单一整串，产出空标签数组）', () => {
      const { foundation, getState } = createFoundation({}, { inputValue: 'foo bar baz' });
      const bySpace = (input: string) => input.split(' ').filter(Boolean);
      const result = foundation.addTagsFromInput(false, bySpace);
      expect(result?.tagsArray).toEqual(['foo', 'bar', 'baz']);
      expect(getState().tagsArray).toEqual(['foo', 'bar', 'baz']);
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

  describe('checkInputMaxLength', () => {
    it('未配置 maxLength：始终放行', () => {
      const { foundation } = createFoundation({}, { inputValue: 'a' });
      expect(foundation.checkInputMaxLength('aaaaaaaaaa')).toBe(true);
    });

    it('单段长度未超限：放行', () => {
      const { foundation } = createFoundation({ maxLength: 5 }, { inputValue: 'ab' });
      expect(foundation.checkInputMaxLength('abc')).toBe(true);
    });

    it('单段长度超限（变长）：拒绝', () => {
      const { foundation } = createFoundation({ maxLength: 3 }, { inputValue: 'abc' });
      expect(foundation.checkInputMaxLength('abcd')).toBe(false);
    });

    it('已超限段内删除字符（变短）：放行，不因为仍然超限而拒绝', () => {
      // 对齐 Semi 语义：只拒绝"变长且超限"，允许在超长段内继续编辑/删除。
      const { foundation } = createFoundation({ maxLength: 3 }, { inputValue: 'abcd' });
      expect(foundation.checkInputMaxLength('abc')).toBe(true);
    });

    it('多段（按 separator 拆分）：只有变长的那一段超限才拒绝，其它段不受影响', () => {
      const { foundation } = createFoundation({ maxLength: 3, separator: ',' }, { inputValue: 'ab,cd' });
      // 第二段 'cd' -> 'cde'，长度 3，未超限，放行。
      expect(foundation.checkInputMaxLength('ab,cde')).toBe(true);
      // 第二段 'cd' -> 'cdef'，长度 4，超限，拒绝。
      expect(foundation.checkInputMaxLength('ab,cdef')).toBe(false);
    });

    it('新增一段且该段超限：拒绝', () => {
      const { foundation } = createFoundation({ maxLength: 2, separator: ',' }, { inputValue: 'ab' });
      expect(foundation.checkInputMaxLength('ab,cde')).toBe(false);
    });

    it('自定义 splitFn：按自定义拆分函数的分段结果校验（对齐 split prop）', () => {
      const { foundation } = createFoundation({ maxLength: 2 }, { inputValue: 'a|b' });
      const customSplit = (input: string) => input.split('|');
      expect(foundation.checkInputMaxLength('a|bcd', customSplit)).toBe(false);
      expect(foundation.checkInputMaxLength('a|bc', customSplit)).toBe(true);
    });
  });
});
