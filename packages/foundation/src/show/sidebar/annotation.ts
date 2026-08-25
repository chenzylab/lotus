export type AnnotationItemType = 'video' | 'text';

export interface AnnotationItem {
  type: AnnotationItemType;
  title?: string;
  url?: string;
  detail?: string;
  logo?: string;
  siteName?: string;
  order?: number;
  img?: string;
  duration?: number;
}

export interface AnnotationGroup {
  header?: string;
  key: string;
  annotations: AnnotationItem[];
}
