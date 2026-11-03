# Kelpie OS V3 — plano de teste seguro do Calamares

Este plano é obrigatório antes de liberar a ISO. Não execute testes destrutivos no computador principal nem em discos que contenham dados importantes.

## Ambiente de teste

- Use uma máquina virtual descartável com snapshot antes de cada cenário.
- Anexe somente discos virtuais criados para o teste; confirme capacidade e identificação do disco antes de iniciar.
- Para UEFI, habilite firmware UEFI na VM e mantenha Secure Boot desativado no primeiro ciclo de compatibilidade.
- Para BIOS legado, use uma VM separada.
- Registre versão da ISO, hash SHA256, configuração da VM, logs e resultado.

## Cenários do instalador

1. **Abrir e cancelar:** iniciar o Live, abrir Calamares, navegar pelas telas e cancelar antes de aplicar alterações. Resultado esperado: nenhum disco alterado.
2. **Disco virtual vazio:** usar um disco virtual descartável, confirmar que o instalador identifica o dispositivo correto, concluir instalação e verificar boot.
3. **Particionamento manual:** criar partições somente no disco virtual descartável; validar ponto de montagem, sistema de arquivos e partição EFI em UEFI.
4. **Dual boot simulado:** usar dois discos virtuais independentes. Nunca usar a unidade física do host. Confirmar que o disco não selecionado permanece inalterado.
5. **Falha e retorno:** interromper antes da confirmação final e verificar que não houve gravação destrutiva; testar logs e mensagens compreensíveis.
6. **Criptografia:** testar em disco virtual, registrar opções, inicialização com senha e recuperação conforme documentação.
7. **Bootloader:** validar entrada UEFI/BIOS, ordem de boot e reinicialização após instalação.

## Critérios de aprovação

- O usuário consegue identificar claramente o disco de destino por modelo/tamanho.
- A tela de resumo permite revisar o destino e as operações antes de executar.
- Nenhuma operação em disco começa antes da confirmação explícita do usuário.
- Cancelar antes da execução não modifica o disco.
- A instalação completa inicia o sistema instalado e preserva o disco virtual não selecionado.
- Logs não contêm dados pessoais desnecessários.
- Cada cenário tem evidência e resultado registrado; falhas bloqueiam a ISO candidata.

## Limite de segurança

A configuração atual usa o módulo padrão de particionamento do Calamares. Este plano não afirma que existe uma proteção adicional implementada no código. Qualquer opção de módulo ou patch de particionamento só será adicionada depois de validar sua compatibilidade com a versão Calamares empacotada no Debian 13 Trixie.
