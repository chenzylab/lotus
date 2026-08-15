import { Layout, Header, Footer, Sider, Content } from '@lotus/ripple';

export function FullSiderLayoutDemo() {
    const commonStyle = { height: '64px', lineHeight: '64px', background: 'var(--lotus-color-fill-0)' };

    return <Layout hasSider style={{ border: '1px solid var(--lotus-color-border)' }}>
        <Sider style={{ width: '120px', background: 'var(--lotus-color-fill-2)' }}>Sider</Sider>
        <Layout>
            <Header style={commonStyle}>Header</Header>
            <Content style={{ height: '300px', lineHeight: '300px' }}>Content</Content>
            <Footer style={commonStyle}>Footer</Footer>
        </Layout>
    </Layout>;
}
