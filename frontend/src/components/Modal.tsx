import type { ReactNode } from 'react'
import { Modal as FbModal, ModalBody, ModalHeader } from 'flowbite-react'

/** Modal de Flowbite con la misma API de antes: se monta abierto y se cierra con onClose. */
export function Modal({ title, onClose, children, size = 'lg' }: {
  title: string
  onClose: () => void
  children: ReactNode
  size?: 'md' | 'lg' | 'xl' | '2xl'
}) {
  return (
    <FbModal show onClose={onClose} size={size} dismissible>
      <ModalHeader>{title}</ModalHeader>
      <ModalBody>{children}</ModalBody>
    </FbModal>
  )
}
