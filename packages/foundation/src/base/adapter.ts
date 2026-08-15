/**
 * Adapter 是 Foundation 与具体渲染框架（当前仅 Ripple）之间的唯一接触面。
 * Foundation 不 import 任何框架包，只依赖这个接口的方法签名——
 * 由 Adapter（.tsrx 组件）实现，在构造时注入给 Foundation。
 */
export interface Adapter<S> {
  getState: () => S;
  setState: (patch: Partial<S>) => void;
}

/**
 * 所有 Foundation 类的公共基类：持有 Adapter 引用，提供 getState/setState 的
 * 简写方法。子类只需扩展业务方法，不需要重复写 constructor 样板代码。
 */
export abstract class Foundation<S> {
  protected adapter: Adapter<S>;

  constructor(adapter: Adapter<S>) {
    this.adapter = adapter;
  }

  protected getState(): S {
    return this.adapter.getState();
  }

  protected setState(patch: Partial<S>): void {
    this.adapter.setState(patch);
  }
}
