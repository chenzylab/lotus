export interface FormLocale {
  requiredError: string;
  patternError: string;
  minError: (min: number) => string;
  maxError: (max: number) => string;
}

export interface InputLocale {
  clear: string;
  showPassword: string;
  hidePassword: string;
}

export interface InputNumberLocale {
  clear: string;
  increase: string;
  decrease: string;
}

export interface TextAreaLocale {
  clear: string;
}

export interface SelectLocale {
  clear: string;
}

export interface LocaleShape {
  code: string;
  dir: 'ltr' | 'rtl';
  Form: FormLocale;
  Input: InputLocale;
  InputNumber: InputNumberLocale;
  TextArea: TextAreaLocale;
  Select: SelectLocale;
}
