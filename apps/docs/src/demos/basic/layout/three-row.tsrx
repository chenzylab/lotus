import { Layout, Header, Footer, Content } from '@lotus/ripple';

export function ThreeRowLayoutDemo() {
    const commonStyle = { height: '64px', lineHeight: '64px', background: 'var(--lotus-color-fill-0)' };

    return <Layout style={{ border: '1px solid var(--lotus-color-border)' }}>
        <Header style={commonStyle}>Header</Header>
        <Content style={{ height: '300px', lineHeight: '300px' }}>Content</Content>
        <Footer style={commonStyle}>Footer</Footer>
    </Layout>;
}
