#!/bin/bash
# 检测当前系统代理设置并设置环境变量

echo "检测当前系统代理设置..."

# 检测 macOS 系统代理
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "检测到 macOS 系统，正在检查网络代理设置..."
    
    # 获取当前活跃的网络服务
    NETWORK_SERVICE=$(networksetup -listnetworkserviceorder | grep -E "(Wi-Fi|Ethernet)" | head -n 1 | sed 's/^([0-9]*) //')
    
    if [ -n "$NETWORK_SERVICE" ]; then
        echo "使用网络服务: $NETWORK_SERVICE"
        
        # 检查 HTTP 代理
        HTTP_PROXY_INFO=$(networksetup -getwebproxy "$NETWORK_SERVICE")
        if echo "$HTTP_PROXY_INFO" | grep -q "Enabled: Yes"; then
            PROXY_HOST=$(echo "$HTTP_PROXY_INFO" | grep "Server:" | awk '{print $2}')
            PROXY_PORT=$(echo "$HTTP_PROXY_INFO" | grep "Port:" | awk '{print $2}')
            if [ -n "$PROXY_HOST" ] && [ -n "$PROXY_PORT" ]; then
                export HTTP_PROXY="http://${PROXY_HOST}:${PROXY_PORT}"
                echo "检测到 HTTP 代理: $HTTP_PROXY"
            fi
        fi
        
        # 检查 HTTPS 代理
        HTTPS_PROXY_INFO=$(networksetup -getsecurewebproxy "$NETWORK_SERVICE")
        if echo "$HTTPS_PROXY_INFO" | grep -q "Enabled: Yes"; then
            PROXY_HOST=$(echo "$HTTPS_PROXY_INFO" | grep "Server:" | awk '{print $2}')
            PROXY_PORT=$(echo "$HTTPS_PROXY_INFO" | grep "Port:" | awk '{print $2}')
            if [ -n "$PROXY_HOST" ] && [ -n "$PROXY_PORT" ]; then
                export HTTPS_PROXY="http://${PROXY_HOST}:${PROXY_PORT}"
                echo "检测到 HTTPS 代理: $HTTPS_PROXY"
            fi
        fi
        
        # 检查 SOCKS 代理
        SOCKS_PROXY_INFO=$(networksetup -getsocksfirewallproxy "$NETWORK_SERVICE")
        if echo "$SOCKS_PROXY_INFO" | grep -q "Enabled: Yes"; then
            PROXY_HOST=$(echo "$SOCKS_PROXY_INFO" | grep "Server:" | awk '{print $2}')
            PROXY_PORT=$(echo "$SOCKS_PROXY_INFO" | grep "Port:" | awk '{print $2}')
            if [ -n "$PROXY_HOST" ] && [ -n "$PROXY_PORT" ]; then
                echo "检测到 SOCKS 代理: socks5://${PROXY_HOST}:${PROXY_PORT}"
                echo "注意：SOCKS 代理需要手动设置 HTTP_PROXY 和 HTTPS_PROXY"
            fi
        fi
    fi
fi

# 检查环境变量中已有的代理设置
if [ -n "$HTTP_PROXY" ] || [ -n "$http_proxy" ]; then
    echo "当前 HTTP_PROXY: ${HTTP_PROXY:-${http_proxy}}"
fi

if [ -n "$HTTPS_PROXY" ] || [ -n "$https_proxy" ]; then
    echo "当前 HTTPS_PROXY: ${HTTPS_PROXY:-${https_proxy}}"
fi

if [ -n "$NO_PROXY" ] || [ -n "$no_proxy" ]; then
    echo "当前 NO_PROXY: ${NO_PROXY:-${no_proxy}}"
fi

# 检测常见的本地代理端口
echo ""
echo "检测常见代理端口..."
COMMON_PORTS=(7890 8080 1080 8888 10809)
for port in "${COMMON_PORTS[@]}"; do
    if lsof -i :$port >/dev/null 2>&1; then
        echo "检测到端口 $port 正在使用（可能是代理服务）"
    fi
done

echo ""
echo "如果需要使用代理，请设置以下环境变量："
echo "export HTTP_PROXY=http://代理地址:端口"
echo "export HTTPS_PROXY=http://代理地址:端口"
echo "export NO_PROXY=localhost,127.0.0.1"
echo ""
echo "然后运行 Docker 构建脚本。"