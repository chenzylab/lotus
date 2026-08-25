import { describe, it, expect } from 'vitest';
import { skillLabel, findSkillSlotInString, getSkillSlotHTML, getSelectSlotHTML, getInputSlotHTML, getCustomSlotAttribute, shouldOpenSkillPanel } from './skill.js';

describe('skillLabel', () => {
  it('label 优先', () => {
    expect(skillLabel({ label: '搜索', value: 'search' })).toBe('搜索');
  });

  it('缺省 label 回退 value', () => {
    expect(skillLabel({ value: 'search' })).toBe('search');
  });

  it('全部缺省回退空串', () => {
    expect(skillLabel({})).toBe('');
  });
});

describe('findSkillSlotInString', () => {
  it('解析完整属性', () => {
    const html = '<skill-slot data-label="搜索" data-value="search" data-template="true"></skill-slot>';
    expect(findSkillSlotInString(html)).toEqual({ label: '搜索', value: 'search', hasTemplate: true });
  });

  it('无 data-value 视为无效标记', () => {
    expect(findSkillSlotInString('<skill-slot data-label="x"></skill-slot>')).toBeUndefined();
  });

  it('无 skill-slot 标签返回 undefined', () => {
    expect(findSkillSlotInString('<p>hello</p>')).toBeUndefined();
  });
});

describe('getSkillSlotHTML', () => {
  it('生成含全部属性的 HTML', () => {
    expect(getSkillSlotHTML({ label: '搜索', value: 'search', hasTemplate: true })).toBe(
      '<skill-slot data-label="搜索" data-value="search" data-template="true"></skill-slot>',
    );
  });

  it('属性值做 HTML 转义防注入', () => {
    expect(getSkillSlotHTML({ label: '<script>', value: 'x' })).toBe('<skill-slot data-label="&lt;script&gt;" data-value="x"></skill-slot>');
  });
});

describe('getSelectSlotHTML', () => {
  it('生成含 options 和 value 的 HTML', () => {
    const html = getSelectSlotHTML(['a', 'b'], 'a');
    expect(html).toContain('options="[&quot;a&quot;,&quot;b&quot;]"');
    expect(html).toContain('value="a"');
  });

  it('缺省 value 时不带 value 属性', () => {
    expect(getSelectSlotHTML(['a'])).not.toContain('value=');
  });
});

describe('getInputSlotHTML', () => {
  it('缺省内容时使用零宽字符', () => {
    expect(getInputSlotHTML('提示')).toBe('<input-slot placeholder="提示">﻿</input-slot>');
  });

  it('有 value 时使用转义后的实际内容', () => {
    expect(getInputSlotHTML('', '<b>')).toBe('<input-slot>&lt;b&gt;</input-slot>');
  });
});

describe('getCustomSlotAttribute', () => {
  it('default 为 true，parseHTML 恒真', () => {
    const attr = getCustomSlotAttribute();
    expect(attr.default).toBe(true);
    expect(attr.parseHTML(null)).toBe(true);
  });

  it('renderHTML 输出 data-custom-slot', () => {
    const attr = getCustomSlotAttribute();
    expect(attr.renderHTML({ isCustomSlot: true })).toEqual({ 'data-custom-slot': true });
    expect(attr.renderHTML({ isCustomSlot: false })).toEqual({ 'data-custom-slot': undefined });
  });
});

describe('shouldOpenSkillPanel', () => {
  it('空输入+匹配热键+有技能项 → true', () => {
    expect(shouldOpenSkillPanel({ key: '/', skillHotKey: '/', isEmpty: true, skillCount: 3 })).toBe(true);
  });

  it('非空输入不触发', () => {
    expect(shouldOpenSkillPanel({ key: '/', skillHotKey: '/', isEmpty: false, skillCount: 3 })).toBe(false);
  });

  it('无技能项不触发', () => {
    expect(shouldOpenSkillPanel({ key: '/', skillHotKey: '/', isEmpty: true, skillCount: 0 })).toBe(false);
  });

  it('键不匹配不触发', () => {
    expect(shouldOpenSkillPanel({ key: 'a', skillHotKey: '/', isEmpty: true, skillCount: 3 })).toBe(false);
  });
});
