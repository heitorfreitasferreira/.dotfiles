return {
  {
    'elcaja5/nvim-strudel',
    ft = { 'strudel' },
    cmd = { 'StrudelPlay', 'StrudelStop', 'StrudelEval', 'StrudelHush' },
    build = function()
      -- ponytail: midi native module fails on Node 26, stub it out
      local root = vim.fn.stdpath('data') .. '/lazy/nvim-strudel/server'
      vim.fn.writefile({
        'export function initMidiPolyfill(){}',
        'export function closeMidi(){}',
      }, root .. '/src/midi-polyfill.ts')
      vim.fn.system('cd ' .. root .. ' && npm install --ignore-scripts && npm run build')
    end,
    opts = {
      audio = { output = 'webaudio' },
      lsp = { enabled = true },
      log = { enabled = true, level = 'info' },
    },
    config = function(_, opts)
      require('strudel').setup(opts)

      vim.treesitter.language.register('javascript', 'strudel')

      vim.api.nvim_create_autocmd('BufWritePost', {
        pattern = '*.strudel',
        callback = function()
          vim.cmd('StrudelEval')
        end,
      })

      vim.keymap.set('n', '<leader>sp', function()
        local ok = pcall(vim.cmd.StrudelPause)
        if not ok then vim.cmd.StrudelPlay() end
      end, { desc = 'Strudel Toggle Play/Pause' })
      vim.keymap.set('n', '<leader>se', '<cmd>StrudelEval<CR>', { desc = 'Strudel Eval' })
      vim.keymap.set('n', '<leader>sh', '<cmd>StrudelHush<CR>', { desc = 'Strudel Hush' })
    end,
  },
}
